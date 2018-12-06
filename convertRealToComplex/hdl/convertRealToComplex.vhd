---------------------------------------------------------------------------
-- (c) Copyright: OscillatorIMP Digital
-- Author : Gwenhael Goavec-Merou<gwenhael.goavec-merou@trabucayre.com>
-- 2015-2018
---------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

Entity convertRealToComplex is 
	generic (
		DATA_SIZE : natural := 8
	);
	port (
		-- input data
		data1_i : in std_logic_vector(DATA_SIZE-1 downto 0);
		data1_en_i: in std_logic;
		data1_eof_i: in std_logic := '0';
		data1_rst_i: in std_logic;
		data1_clk_i: in std_logic;
		data2_i : in std_logic_vector(DATA_SIZE-1 downto 0) := (others => '0');
		data2_en_i: in std_logic := '1';
		data2_rst_i: in std_logic := '1';
		data2_eof_i: in std_logic := '1';
		data2_clk_i: in std_logic := '1';
		-- for the next component
		data_i_o  : out std_logic_vector(DATA_SIZE-1 downto 0);
		data_q_o  : out std_logic_vector(DATA_SIZE-1 downto 0);
		data_eof_o : out std_logic;
		data_rst_o : out std_logic;
		data_en_o : out std_logic;
		data_clk_o : out std_logic
	);
end entity;

---------------------------------------------------------------------------
Architecture convertRealToComplex_1 of convertRealToComplex is
begin
	data_clk_o <= data1_clk_i and data2_clk_i;	
	data_rst_o <= data1_rst_i and data2_rst_i;
	data_i_o <= data1_i;
	data_q_o <= data2_i;
	data_eof_o <= data1_eof_i and data2_eof_i;
	data_en_o <= data1_en_i and data2_en_i;
end architecture convertRealToComplex_1;

