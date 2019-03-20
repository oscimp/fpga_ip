---------------------------------------------------------------------------
-- (c) Copyright: OscillatorIMP Digital
-- Author : Gwenhael Goavec-Merou<gwenhael.goavec-merou@trabucayre.com>
-- Creation date : 2016/10/27
---------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

Entity axiStreamToReal is 
	generic (
		DATA_SIZE : natural := 32
	);
	port (
		rst_i : in std_logic;
		-- output data
		data_o : out std_logic_vector(DATA_SIZE-1 downto 0);
		data_en_o: out std_logic;
		data_clk_o: out std_logic;
		data_rst_o: out std_logic;
		-- input data
		s00_axis_aclk	: in std_logic;
		s00_axis_tdata  : in std_logic_vector(DATA_SIZE-1 downto 0);
		s00_axis_tready  : out std_logic;
		s00_axis_tvalid  : in std_logic
	);
end entity;

---------------------------------------------------------------------------
Architecture axiStreamToReal_1 of axiStreamToReal is
begin
	data_o <= s00_axis_tdata;
	data_en_o <= s00_axis_tvalid;
	data_clk_o <= s00_axis_aclk;
	s00_axis_tready <= '1';
	data_rst_o <= rst_i;
end architecture axiStreamToReal_1;

