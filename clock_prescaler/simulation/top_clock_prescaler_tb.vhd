library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
USE std.textio.ALL;

entity top_clock_prescaler_tb is
end entity top_clock_prescaler_tb;

architecture RTL of top_clock_prescaler_tb is
	file final_result_file: text open write_mode is "./result.txt";
    
	CONSTANT HALF_PERIOD : time := 5.0 ns;  -- Half clock period
	signal clk, rst, en_s, en_out : std_logic;
    
begin
	clock_prescaler_inst : entity work.clock_prescaler
	port map (rst => rst, clk => clk, 
		en_out => en_out);

	stimulis : process
	begin
	rst <= '1';
	wait until rising_edge(clk);
	rst <= '1';
	wait until rising_edge(clk);
	wait until rising_edge(clk);
	wait until rising_edge(clk);
	rst <= '0';
	wait for 10 ns;
	wait for 10 ns;
	wait for 10 ns;
	wait until rising_edge(clk);
	wait until rising_edge(clk);
	wait until rising_edge(clk);
	wait for 10 us;
	wait for 10 us;
	wait for 10 us;
	wait for 10 us;
	wait until rising_edge(clk);
	wait until rising_edge(clk);
	--wait for 1 ms;
	assert false report "End of test" severity error;
	end process stimulis;

--	store_result : process(clk, rst)
--		use Std.TextIO.all;
--		use IEEE.Std_Logic_TextIO.all;
--		variable lp: line;
--		variable pv: Std_Logic;
--	begin
--		if (rst = '1') then
--		elsif rising_edge(clk) then
			--write(lp, integer'image(to_integer(unsigned(g1_full_s))));
            --write(lp, string'(" "));
			--write(lp, integer'image(to_integer(unsigned(cacode_s))));
--			int_loop : for i in 0 to 31 loop
--			write(lp, integer'image(to_integer(unsigned(truc_s(i)))));
--            write(lp, string'(" "));
--			end loop int_loop;
--			writeline(final_result_file, lp);
--		end if;
--	end process;
	
	clockp : process
	begin
		clk <= '1';
		wait for HALF_PERIOD;
		clk <= '0';
		wait for HALF_PERIOD;
	end process clockp;

end architecture RTL;
