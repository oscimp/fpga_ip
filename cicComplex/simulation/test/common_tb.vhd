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
		DECIMATE_FACTOR : natural := 32;
		DIFFERENTIAL_DELAY : natural := 4;
		ORDER : natural := 4;
		DATA_IN_SIZE : natural := 25;
		DATA_OUT_SIZE : natural := 25
	);
end entity common_tb;

Architecture rtl of common_tb is
    constant REGISTER_SIZE : coeff_t(0 to ORDER*2) := CicRegSize(BIT_PRUNING, 
															DATA_IN_SIZE,
															DATA_OUT_SIZE,
															DECIMATE_FACTOR,
															ORDER,
															DIFFERENTIAL_DELAY);
begin
    process 
    begin
		report "Stage(j)   Accum width";
		for Stage in 0 to 2*ORDER-1 loop
    		report integer'image(Stage+1) & "            " & integer'image(REGISTER_SIZE(Stage));
		end loop;
		report integer'image(2*ORDER+1) & "            " & integer'image(REGISTER_SIZE(2*ORDER));
        wait;
    end process;
end architecture rtl;