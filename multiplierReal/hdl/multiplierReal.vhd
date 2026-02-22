---------------------------------------------------------------------------
-- (c) Copyright: OscillatorIMP Digital
-- Author : Gwenhael Goavec-Merou<gwenhael.goavec-merou@trabucayre.com>
-- Creation date : 2020/01/30
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

entity multiplierReal is
	generic (
		SIGNED_FORMAT : boolean := true;
		ENABLE_SEL : string := "and";
		DATA1_IN_SIZE : natural := 16;
		DATA2_IN_SIZE : natural := 16;
		DATA_OUT_SIZE : natural := 2*16
	);
	port (
		-- data1 interface
		data1_i: in std_logic_vector(DATA1_IN_SIZE-1 downto 0);
		data1_en_i : in std_logic;
		data1_eof_i : in std_logic;
		data1_sof_i : in std_logic;
		data1_clk_i : in std_logic;
		data1_rst_i : in std_logic;
		-- data2 interface
		data2_i: in std_logic_vector(DATA2_IN_SIZE-1 downto 0);
		data2_en_i : in std_logic;
		data2_eof_i : in std_logic;
		data2_sof_i : in std_logic;
		data2_clk_i : in std_logic;
		data2_rst_i : in std_logic;
		-- next
		data_o : out std_logic_vector(DATA_OUT_SIZE-1 downto 0);
		data_en_o  : out std_logic;
		data_eof_o  : out std_logic;
		data_sof_o  : out std_logic;
		data_clk_o : out std_logic;
		data_rst_o : out std_logic
	);
end multiplierReal;

architecture Behavioral of multiplierReal is
	constant INT_DATA_SZ : natural := DATA1_IN_SIZE + DATA2_IN_SIZE;

	-- input latches
	signal data1_in_s                     : std_logic_vector(DATA1_IN_SIZE-1 downto 0);
	signal data2_in_s                     : std_logic_vector(DATA2_IN_SIZE-1 downto 0);
	signal data1_in_en_s, data2_in_en_s   : std_logic;
	signal data1_in_eof_s, data2_in_eof_s : std_logic;
	signal data1_in_sof_s, data2_in_sof_s : std_logic;

	-- mult
	signal data_s     : std_logic_vector(INT_DATA_SZ-1 downto 0);
	signal data_clk_s  : std_logic;
	signal data_rst_s  : std_logic;
	signal data_en_s  : std_logic;
	signal data_eof_s : std_logic;
	signal data_sof_s : std_logic;
begin

	data_clk_o <= data_clk_s;
	data_rst_o <= data_rst_s;

	process(data1_clk_i)
	begin
		if rising_edge(data1_clk_i) then
			if data1_rst_i = '1' then
				data1_in_s <= (others => '0');
				data1_in_en_s <= '0';
				data1_in_eof_s <= '0';
			else
				data1_in_s <= data1_i;
				data1_in_en_s <= data1_en_i;
				data1_in_eof_s <= data1_eof_i;
			end if;
		end if;
	end process;

	process(data2_clk_i)
	begin
		if rising_edge(data2_clk_i) then
			if data2_rst_i = '1' then
				data2_in_s <= (others => '0');
				data2_in_en_s <= '0';
				data2_in_eof_s <= '0';
			else
				data2_in_s <= data2_i;
				data2_in_en_s <= data2_en_i;
				data2_in_eof_s <= data2_eof_i;
			end if;
		end if;
	end process;

	signed_mult: if SIGNED_FORMAT = true generate
		data_s <= std_logic_vector(signed(data1_in_s) * signed(data2_in_s));
	end generate signed_mult;
	unsigned_mult: if SIGNED_FORMAT = false generate
		data_s <= std_logic_vector(unsigned(data1_in_s) * unsigned(data2_in_s));
	end generate unsigned_mult;

	-- data1_in and data2_in for CANDR and en
	and_sel: if ENABLE_SEL = "and" generate
		data_clk_s <= data1_clk_i;
		data_rst_s <= data1_rst_i;
		data_en_s <= data1_in_en_s and data2_in_en_s;
		data_eof_s <= data1_in_eof_s and data2_in_eof_s;
	end generate and_sel;

	-- data1_in for CANDR and en
	data1_sel: if ENABLE_SEL = "data1" generate
		data_clk_s <= data1_clk_i;
		data_rst_s <= data1_rst_i;
		data_en_s <= data1_in_en_s;
		data_eof_s <= data1_in_eof_s;
	end generate data1_sel;

	-- data2_in for CANDR and en
	data2_sel: if ENABLE_SEL = "data2" generate
		data_clk_s <= data2_clk_i;
		data_rst_s <= data2_rst_i;
		data_en_s <= data2_in_en_s;
		data_eof_s <= data2_in_eof_s;
	end generate data2_sel;

	redim_inst: entity work.multiplierReal_redim
	generic map (SIGNED_FORMAT => SIGNED_FORMAT, IN_SZ => INT_DATA_SZ,
		OUT_SZ => DATA_OUT_SIZE)
	port map (clk_i => data_clk_s, rst_i => data_rst_s,
		data_en_i => data_en_s, data_i => data_s,
		data_eof_i => data_eof_s, data_sof_i => data_sof_s,
		data_en_o => data_en_o, data_o => data_o,
		data_eof_o => data_eof_o, data_sof_o => data_sof_o);

end Behavioral;
