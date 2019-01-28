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
		dataI_i : in std_logic_vector(DATA_SIZE-1 downto 0);
		dataI_en_i: in std_logic;
		dataI_eof_i: in std_logic := '0';
		dataI_rst_i: in std_logic;
		dataI_clk_i: in std_logic;
		dataQ_i : in std_logic_vector(DATA_SIZE-1 downto 0) := (others => '0');
		dataQ_en_i: in std_logic := '1';
		dataQ_rst_i: in std_logic := '1';
		dataQ_eof_i: in std_logic := '1';
		dataQ_clk_i: in std_logic := '1';
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
	data_clk_o <= dataI_clk_i and dataQ_clk_i;
	data_rst_o <= dataI_rst_i and dataQ_rst_i;
	data_i_o <= dataI_i;
	data_q_o <= dataQ_i;
	data_eof_o <= dataI_eof_i and dataQ_eof_i;
	data_en_o <= dataI_en_i and dataQ_en_i;
end architecture convertRealToComplex_1;

