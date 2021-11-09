library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity const_complex is 
	generic(
		DATA_SIZE : natural := 16;
		INT_REAL_PART_OUT_VALUE : integer := 0;
		INT_IMAG_PART_OUT_VALUE : integer := 0
		);
	port(
		--Syscon signals
		ref_clk_i : in std_logic;
		ref_rst_i : in std_logic;
		data_i_o  : out std_logic_vector(DATA_SIZE - 1 downto 0);
		data_q_o  : out std_logic_vector(DATA_SIZE - 1 downto 0);
		data_en_o : out std_logic;
		data_clk_o : out std_logic;
		data_rst_o : out std_logic
	);
end entity const_complex;
architecture bhv of const_complex is
begin
	data_i_o <= std_logic_vector(to_signed(INT_REAL_PART_OUT_VALUE,data_i_o'length));
	data_q_o <= std_logic_vector(to_signed(INT_IMAG_PART_OUT_VALUE,data_q_o'length));
	data_en_o <= '1';
	data_clk_o <= ref_clk_i;
	data_rst_o <= ref_rst_i;
end architecture bhv;
