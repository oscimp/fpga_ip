library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

Entity wb_axi_to_dac is 
	generic(
		id                    : natural := 1;
		DATA_A_EN_ALWAYS_HIGH : boolean := false;
		DATA_B_EN_ALWAYS_HIGH : boolean := false;
		SYNCHRONIZE_CHAN      : boolean := false;
		DATA_SIZE             : natural := 16;
		BUS_SIZE              : natural := 16
	);
	port (
		-- Syscon signals
		reset         : in std_logic;
		clk           : in std_logic;
		-- Wishbone signals
		addr_i        : in std_logic_vector(1 downto 0);
		wbs_write     : in std_logic;
		wbs_writedata : in std_logic_vector( BUS_SIZE-1 downto 0);
		wbs_read      : in std_logic;
		wbs_readdata  : out std_logic_vector( BUS_SIZE-1 downto 0);
		-- conf
		data_a_en_always_high_o : out std_logic;
		data_b_en_always_high_o : out std_logic;
		synchronize_chan_o      : out std_logic;
		-- data
		data_a_o      : out std_logic_vector(DATA_SIZE-1 downto 0);
		data_a_en_o   : out std_logic;
		data_b_o      : out std_logic_vector(DATA_SIZE-1 downto 0);
		data_b_en_o   : out std_logic
	);
end entity wb_axi_to_dac;

Architecture bhv of wb_axi_to_dac is
	function bool_to_sl(b_val: boolean) return std_logic is
	begin
		if b_val then
			return('1');
		else
			return('0');
		end if;
	end function bool_to_sl;

	constant REG_ID     : std_logic_vector := "00";
	constant REG_DATA_A : std_logic_vector := "01";
	constant REG_DATA_B : std_logic_vector := "10";
	constant REG_CONF   : std_logic_vector := "11";
	signal data_a_en_always_high_s : std_logic;
	signal data_b_en_always_high_s : std_logic;
	signal synchronize_chan_s      : std_logic;
	signal data_a_s                : std_logic_vector(BUS_SIZE-1 downto 0);
	signal data_b_s                : std_logic_vector(BUS_SIZE-1 downto 0);
	signal readdata_s              : std_logic_vector(BUS_SIZE-1 downto 0);
	signal readdata_next_s         : std_logic_vector(BUS_SIZE-1 downto 0);
begin
	data_a_o <= data_a_s(DATA_SIZE-1 downto 0);
	data_a_en_always_high_o <= data_a_en_always_high_s;
	data_b_o <= data_b_s(DATA_SIZE-1 downto 0);
	data_b_en_always_high_o <= data_b_en_always_high_s;
	synchronize_chan_o <= synchronize_chan_s;

	wbs_readdata <= readdata_s;

	-- manage register
	write_bloc : process(clk) begin
		 if rising_edge(clk) then
		 	if reset = '1' then 
				data_a_s <= (others => '0');
				data_a_en_o <= '0';
				data_b_s <= (others => '0');
				data_b_en_o <= '0';
				data_a_en_always_high_s <= bool_to_sl(DATA_A_EN_ALWAYS_HIGH);
				data_b_en_always_high_s <= bool_to_sl(DATA_B_EN_ALWAYS_HIGH);
				synchronize_chan_s <= bool_to_sl(SYNCHRONIZE_CHAN);
		 	else
				data_a_s <= data_a_s;
				data_a_en_o <= '0';
				data_b_s <= data_b_s;
				data_b_en_o <= '0';
				data_a_en_always_high_s <= data_a_en_always_high_s;
				data_b_en_always_high_s <= data_b_en_always_high_s;
				synchronize_chan_s <= synchronize_chan_s;
				if wbs_write = '1' then
			   		case addr_i is
					when REG_DATA_A =>
						data_a_s <= wbs_writedata;
						data_a_en_o <= '1';
					when REG_DATA_B =>
						data_b_s <= wbs_writedata;
						data_b_en_o <= '1';
					when REG_CONF =>
						synchronize_chan_s <= wbs_writedata(0);
						data_a_en_always_high_s <= wbs_writedata(1);
						data_b_en_always_high_s <= wbs_writedata(2);
					when others =>
					end case;
				end if;
			end if;
		 end if;
	end process write_bloc;

	read_async: process(addr_i, data_a_s, data_b_s,
						data_a_en_always_high_s, data_b_en_always_high_s,
						synchronize_chan_s) begin
		case addr_i is
		when REG_ID =>
			readdata_next_s <= std_logic_vector(to_unsigned(id,BUS_SIZE));
		when REG_DATA_A =>
			readdata_next_s <= data_a_s;
		when REG_DATA_B =>
			readdata_next_s <= data_b_s;
		when REG_CONF =>
			readdata_next_s <= (BUS_SIZE-1 downto 3 => '0')
							& data_a_en_always_high_s
							& data_b_en_always_high_s
							& synchronize_chan_s;
		end case;
	end process read_async;

	read_bloc : process(clk)
	begin
		 if rising_edge(clk) then
		 	if reset = '1' then 
				readdata_s <= (others => '0');
			elsif wbs_read = '1' then
			 	readdata_s <= readdata_next_s;
			else
		 		readdata_s <= readdata_s;
			end if;
		 end if;
	end process read_bloc;

end architecture bhv;

