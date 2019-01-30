library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

Entity convertComplexToReal is 
	generic (
		DATA_SIZE : natural := 8
	);
	port (
		-- output data
		data1_o : out std_logic_vector(DATA_SIZE-1 downto 0);
		data1_en_o: out std_logic;
		data1_eof_o: out std_logic;
		data1_clk_o: out std_logic;
		data1_rst_o: out std_logic;
		data2_o : out std_logic_vector(DATA_SIZE-1 downto 0);
		data2_en_o: out std_logic;
		data2_eof_o: out std_logic;
		data2_clk_o: out std_logic;
		data2_rst_o: out std_logic;
		-- input data
		data_i_i  : in std_logic_vector(DATA_SIZE-1 downto 0);
		data_q_i  : in std_logic_vector(DATA_SIZE-1 downto 0);
		data_eof_i : in std_logic;
		data_en_i : in std_logic;
		data_rst_i : in std_logic;
		data_clk_i : in std_logic
	);
end entity;

---------------------------------------------------------------------------
Architecture convertComplexToReal_1 of convertComplexToReal is
begin
	
	data1_o <= data_i_i;
	data2_o <= data_q_i;

	data1_en_o <= data_en_i;
	data2_en_o <= data_en_i;

	data1_eof_o <= data_eof_i;
	data2_eof_o <= data_eof_i;

	data1_clk_o <= data_clk_i;
	data2_clk_o <= data_clk_i;

	data1_rst_o <= data_rst_i;
	data2_rst_o <= data_rst_i;
	
end architecture convertComplexToReal_1;

