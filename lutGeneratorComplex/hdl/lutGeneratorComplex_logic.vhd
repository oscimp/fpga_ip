-- Copyright 2023 Gwenhael Goavec-Merou
-- gwenhael.goavec-merou@trabucayre.com
--
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

entity lutGeneratorComplex_logic is
	generic (
		PRESC_SIZE : natural := 12; --! size (in bit) to the prescaler counter
		ADDR_SIZE  : natural := 10; --! ram depth
		DATA_SIZE  : natural := 16  --! size of samples stored into the RAM
	);
	port (
		clk          : in std_logic; --! clk used for prescaler and generator
		reset        : in std_logic; --! rst used for prescaler and generator
		cpu_clk      : in std_logic; --! clk used for RAM storage
		-- from AXI
		-- i configuration
		data_en_i_i  : in std_logic;
		data_adr_i_i : in std_logic_vector(ADDR_SIZE-1 downto 0);
		data_i_i     : in std_logic_vector(DATA_SIZE-1 downto 0);
		-- q configuration
		data_en_q_i  : in std_logic;
		data_adr_q_i : in std_logic_vector(ADDR_SIZE-1 downto 0);
		data_q_i     : in std_logic_vector(DATA_SIZE-1 downto 0);
		-- prescaler
		prescaler_i  : in std_logic_vector(PRESC_SIZE-1 downto 0);
		-- control
		enable_i     : in std_logic;
		ram_length_i : in std_logic_vector(ADDR_SIZE-1 downto 0);
		-- for next
		data_en_o    : out std_logic;
		data_eof_o   : out std_logic;
		data_sof_o   : out std_logic;
		data_i_o     : out std_logic_vector(DATA_SIZE-1 downto 0);
		data_q_o     : out std_logic_vector(DATA_SIZE-1 downto 0)
	);
end lutGeneratorComplex_logic;

architecture bhv of lutGeneratorComplex_logic is
	constant ALL_ZERO      : unsigned(PRESC_SIZE-1 downto 0) := (PRESC_SIZE-1 downto 0 => '0');
	-- prescaler
	signal prescaler_s     : unsigned(PRESC_SIZE-1 downto 0);
	signal prescaler_uns_i : unsigned(PRESC_SIZE-1 downto 0);
	signal tick_s          : std_logic;
	-- ram counter
	signal ram_adr_s       : unsigned(ADDR_SIZE-1 downto 0);
	signal ram_adr_slv_s   : std_logic_vector(ADDR_SIZE-1 downto 0);
	signal ram_length_uns_i: unsigned(ADDR_SIZE-1 downto 0);
	-- ram management
	signal data_i_s        : std_logic_vector(DATA_SIZE-1 downto 0);
	signal data_q_s        : std_logic_vector(DATA_SIZE-1 downto 0);
	signal data_en_s       : std_logic;
	signal data_eof_s      : std_logic;
	signal data_sof_s      : std_logic;

begin
	data_en_o  <= data_en_s and enable_i;
	data_eof_o <= data_eof_s and enable_i;
	data_sof_o <= data_sof_s and enable_i;
	-----------------------------------
	-----------------------------------
	--           prescaler           --
	-----------------------------------
	-----------------------------------

	prescaler_uns_i <= unsigned(prescaler_i);
	tick_s <= '1' when prescaler_s = ALL_ZERO else '0';
	process(clk) begin
		if rising_edge(clk) then
			prescaler_s <= prescaler_s - 1;

			if (reset or not enable_i or tick_s) = '1' then
				prescaler_s <= prescaler_uns_i - 1;
			end if;
		end if;
	end process;

	-----------------------------------
	-----------------------------------
	--          ram counter          --
	-----------------------------------
	-----------------------------------

	ram_length_uns_i <= unsigned(ram_length_i);
	ram_adr_slv_s    <= std_logic_vector(ram_adr_s);
	process(clk) begin
		if rising_edge(clk) then
			if tick_s = '1' then
				ram_adr_s <= ram_adr_s + 1;
				if ram_adr_s = ram_length_uns_i - 1 then
					ram_adr_s <= (others => '0');
				end if;
			end if;

			if (reset or not enable_i) = '1' then
				ram_adr_s <= (others => '0');
			end if;
		end if;
	end process;

	-----------------------------------
	-----------------------------------
	--         mem management        --
	-----------------------------------
	-----------------------------------

	process(clk) begin
		if rising_edge(clk) then
			data_en_s  <= tick_s;
			data_eof_s <= '0';
			data_sof_s <= '0';
			if tick_s = '1' then
				data_i_o  <= data_i_s;
				data_q_o  <= data_q_s;
				if ram_adr_s = 0 then
					data_sof_s <= '1';
				end if;
				if ram_adr_s = ram_length_uns_i -1 then
					data_eof_s <= '1';
				end if;
			end if;

			if (reset or not enable_i) = '1' then
				data_en_s  <= '0';
				data_sof_s <= '0';
				data_eof_s <= '0';
				data_i_o   <= (others => '0');
				data_q_o   <= (others => '0');
			end if;
		end if;
	end process;

	ram_i_msb: entity work.lutGeneratorComplex_storage
    generic map (DATA => DATA_SIZE, ADDR => ADDR_SIZE)
    port map (clk_a => cpu_clk, clk_b => clk,
        we_a => data_en_i_i, addr_a => data_adr_i_i,
        din_a => data_i_i, dout_a => open,
        we_b => '0', addr_b => ram_adr_slv_s,
        din_b => (DATA_SIZE-1 downto 0 => '0'),
        dout_b => data_i_s);
	ram_q_msb: entity work.lutGeneratorComplex_storage
    generic map (DATA => DATA_SIZE, ADDR => ADDR_SIZE)
    port map (clk_a => cpu_clk, clk_b => clk,
        we_a => data_en_q_i, addr_a => data_adr_q_i,
        din_a => data_q_i, dout_a => open,
        we_b => '0', addr_b => ram_adr_slv_s,
        din_b => (DATA_SIZE-1 downto 0 => '0'),
        dout_b => data_q_s);

end bhv;
