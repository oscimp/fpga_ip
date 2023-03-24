library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

Entity wb_lutGeneratorComplex is 
    generic(
		PRESC_SIZE : natural := 12;
		ADDR_SIZE  : natural := 10;
		DATA_SIZE  : natural := 16;
        wb_size    : natural := 16
    );
    port (
		-- Syscon signals
		reset         : in  std_logic;
		clk           : in  std_logic;
		-- Wishbone signals
		addr_i        : in  std_logic_vector(2 downto 0);
		wen_i         : in  std_logic ;
		wrdata_i      : in  std_logic_vector( wb_size-1 downto 0);
		ren_i         : in  std_logic ;
		rddata_o      : out std_logic_vector( wb_size-1 downto 0);
		-- configuration
		---- RAM
		data_en_i_o   : out std_logic;
		data_i_o      : out std_logic_vector(DATA_SIZE-1 downto 0);
		data_addr_i_o : out std_logic_vector(ADDR_SIZE-1 downto 0);
		data_en_q_o   : out std_logic;
		data_q_o      : out std_logic_vector(DATA_SIZE-1 downto 0);
		data_addr_q_o : out std_logic_vector(ADDR_SIZE-1 downto 0);
		---- control
		enable_o      : out std_logic;
		ram_length_o  : out std_logic_vector(ADDR_SIZE-1 downto 0);
		prescaler_o   : out std_logic_vector(PRESC_SIZE-1 downto 0)
    );
end entity wb_lutGeneratorComplex;

Architecture bhv of wb_lutGeneratorComplex is
	constant REG_RAM_LENGTH : std_logic_vector := "000";
	constant REG_PRESCALER  : std_logic_vector := "001";
	constant REG_ENABLE     : std_logic_vector := "010";
	constant REG_DATA_I     : std_logic_vector := "011";
	constant REG_DATA_Q     : std_logic_vector := "100";
	constant REG_RST_ADDR   : std_logic_vector := "101";

	signal rddata_s     : std_logic_vector(wb_size-1 downto 0);
	signal rst_addr_s   : std_logic;
	signal data_en_i_s  : std_logic;
	signal addr_i_s     : std_logic_vector(ADDR_SIZE-1 downto 0);
	signal data_en_q_s  : std_logic;
	signal addr_q_s     : std_logic_vector(ADDR_SIZE-1 downto 0);
	signal ram_length_s : std_logic_vector(ADDR_SIZE-1 downto 0);
	signal prescaler_s  : std_logic_vector(PRESC_SIZE-1 downto 0);
	signal enable_s     : std_logic;
begin
	data_en_i_o   <= data_en_i_s;
	data_addr_i_o <= addr_i_s;
	data_en_q_o   <= data_en_q_s;
	data_addr_q_o <= addr_q_s;
	prescaler_o   <= prescaler_s;
	ram_length_o  <= ram_length_s;
	enable_o      <= enable_s;

	ram_proc: process(clk) begin
		if rising_edge(clk) then
			if data_en_i_s = '1' then
				addr_i_s <= std_logic_vector(unsigned(addr_i_s) + 1);
			end if;
			if data_en_q_s = '1' then
				addr_q_s <= std_logic_vector(unsigned(addr_q_s) + 1);
			end if;

			if (reset or rst_addr_s) = '1' then
				addr_q_s <= (others => '0');
				addr_i_s <= (others => '0');
			end if;
		end if;
	end process ram_proc;

	-- manage register
	write_bloc : process(clk) begin
		if rising_edge(clk) then
			data_en_i_s <= '0';
			data_en_q_s <= '0';
			rst_addr_s  <= '0';
			if (wen_i = '1' ) then
				case addr_i is
				when REG_RAM_LENGTH =>
					ram_length_s <= wrdata_i(ADDR_SIZE-1 downto 0);
				when REG_PRESCALER =>
					prescaler_s <= wrdata_i(PRESC_SIZE-1 downto 0);
				when REG_ENABLE =>
					enable_s <= wrdata_i(0);
				when REG_DATA_I =>
					data_en_i_s <= '1';
					data_i_o <= wrdata_i(DATA_SIZE-1 downto 0);
				when REG_DATA_Q =>
					data_en_q_s <= '1';
					data_q_o <= wrdata_i(DATA_SIZE-1 downto 0);
				when REG_RST_ADDR =>
					rst_addr_s <= '1';
				when others =>
				end case;
		 	end if;
			if reset = '1' then 
				data_en_i_s  <= '0';
				data_i_o     <= (others => '0');
				data_en_q_s  <= '0';
				data_q_o     <= (others => '0');
				prescaler_s  <= (PRESC_SIZE-1 downto 1 => '0') & '1';
				ram_length_s <= (others => '0');
				enable_s     <= '0';
			end if;
		end if;
	end process write_bloc;

	comb_rd_proc: process(addr_i, ram_length_s, prescaler_s, enable_s) begin
		case addr_i is
		when REG_RAM_LENGTH =>
			rddata_s <= (wb_size-1 downto ADDR_SIZE => '0') &  ram_length_s;
		when REG_PRESCALER =>
			rddata_s <= (wb_size-1 downto PRESC_SIZE => '0') & prescaler_s;
		when REG_ENABLE =>
			rddata_s <= (wb_size-1 downto 1 => '0') & enable_s;
		when others =>
			rddata_s <= (others => '1');
		end case;
	end process comb_rd_proc;

	read_bloc : process(clk) begin
		if rising_edge(clk) then
			if ren_i = '1' then
				rddata_o <= rddata_s;
			end if;
			if reset = '1' then
				rddata_o <= (others => '0');
			end if;
		end if;
	end process read_bloc;

end architecture bhv;

