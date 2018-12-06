---------------------------------------------------------------------------
-- (c) Copyright: OscillatorIMP Digital
-- Author : Gwenhael Goavec-Merou<gwenhael.goavec-merou@trabucayre.com>
-- Creation date : 2014/10/14
---------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

entity dupplReal_1_to_2 is
	generic (
		DATA_SIZE : natural := 8
	);
	port (
		-- DATA in
		data_en_i : in std_logic;
		data_eof_i : in std_logic;
		data_clk_i : in std_logic;
		data_rst_i : in std_logic;
		data_i: in std_logic_vector(DATA_SIZE-1 downto 0);
		-- next
		data1_en_o : out std_logic;
		data1_eof_o : out std_logic;
		data1_clk_o : out std_logic;
		data1_rst_o : out std_logic;
		data1_o : out std_logic_vector(DATA_SIZE-1 downto 0);
		data2_en_o : out std_logic;
		data2_eof_o : out std_logic;
		data2_clk_o : out std_logic;
		data2_rst_o : out std_logic;
		data2_o : out std_logic_vector(DATA_SIZE-1 downto 0)
	);
end dupplReal_1_to_2;

architecture Behavioral of dupplReal_1_to_2 is
begin
	data1_o <= data_i;
	data1_en_o <= data_en_i;
	data1_eof_o <= data_eof_i;
    data1_clk_o <= data_clk_i;
    data1_rst_o <= data_rst_i;
    
	data2_o <= data_i;
	data2_en_o <= data_en_i;
	data2_eof_o <= data_eof_i;
	data2_clk_o <= data_clk_i;
	data2_rst_o <= data_rst_i;
end Behavioral;

