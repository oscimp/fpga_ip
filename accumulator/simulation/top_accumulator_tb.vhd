library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
USE std.textio.ALL;
--use work.sp_vision_test_pkg.all;

entity top_accumulator_tb is
end entity top_accumulator_tb;

architecture RTL of top_accumulator_tb is
	signal reset : std_logic;
	CONSTANT HALF_PERIODE : time := 5.0 ns;  -- Half clock period
	signal clk : std_logic;

begin
	inst: Entity work.accumulator
	generic map (
		NB_ACCUM => 10)
	port map (
		data_rst_i => reset,
		data_clk_i => clk);

    stimulis : process
    begin
	reset <= '1';
	wait until rising_edge(clk);
	reset <= '1';
	wait until rising_edge(clk);
	wait until rising_edge(clk);
	wait until rising_edge(clk);
	reset <= '0';
    wait for 100 us;
    assert false report "End of test" severity error;
    end process stimulis;
    
    clockp : process
    begin
        clk <= '1';
        wait for HALF_PERIODE;
        clk <= '0';
        wait for HALF_PERIODE;
    end process clockp;
    
end architecture RTL;
