---------------------------------------------------------------------------
-- (c) Copyright: OscillatorIMP Digital
-- Author : Gwenhael Goavec-Merou<gwenhael.goavec-merou@trabucayre.com>
-- 2013-2019
---------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

entity mean_vector_axi_shift is
	generic (
		SHIFT_SIZE : natural := 10;
		DATA_I_SIZE: natural := 32;
		DATA_O_SIZE : natural := 34
	);
	port (
		shift_i : in std_logic_vector(SHIFT_SIZE-1 downto 0);
		data_i 	: in std_logic_vector(DATA_I_SIZE-1 downto 0);
		data_o 	: out std_logic_vector(DATA_O_SIZE-1 downto 0)
	);
end mean_vector_axi_shift;

architecture Behavioral of mean_vector_axi_shift is
	constant MUX_SZ : natural := 2**SHIFT_SIZE;
	type mux_array is array (natural range 0 to MUX_SZ-1) of 
                std_logic_vector(DATA_O_SIZE-1 downto 0);
                --std_logic_vector(data_o'range);
    signal array_val: mux_array;
begin

	t : for i in 0 to MUX_SZ-1 generate
		array_val(i) <= data_i(DATA_O_SIZE+i-1 downto i);
	end generate t;

	data_o <= array_val(to_integer(unsigned(shift_i)));

end architecture Behavioral;
