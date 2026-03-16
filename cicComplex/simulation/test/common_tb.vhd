library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
use IEEE.math_real.all;

library work;
use work.common.all;


Entity common_tb is 
	generic (
		BIT_PRUNING : boolean := true;
		data_signed : boolean := true;
		DECIMATE_FACTOR : natural := 8;
		DIFFERENTIAL_DELAY : natural := 1;
		ORDER : natural := 4;
		DATA_IN_SIZE : natural := 16;
		DATA_OUT_SIZE : natural := 23
	);
end entity common_tb;

Architecture rtl of common_tb is
    signal REGISTER_SIZE : coeff_t(1 to ORDER*2);
begin
    process 
    begin
        REGISTER_SIZE <= CicRegSize(BIT_PRUNING, DATA_IN_SIZE, DATA_OUT_SIZE,
                            DECIMATE_FACTOR, ORDER, DIFFERENTIAL_DELAY);
        wait;
    end process;
end architecture rtl;