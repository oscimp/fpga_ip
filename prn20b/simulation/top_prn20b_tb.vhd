library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
USE std.textio.ALL;

entity top_prn20b_tb is
end entity top_prn20b_tb;

architecture RTL of top_prn20b_tb is
	file final_result_file: text open write_mode is "./result.txt";

	signal reset : std_logic;
	CONSTANT HALF_PERIOD : time := 5.0 ns;  -- Half clock period
	signal clk : std_logic;
	
	signal bit_s : std_logic;
	signal prn_s : std_logic_vector(19 downto 0);

	signal clk_gen_s, tick_s : std_logic;
begin

	prn20b_inst : entity work.prn20b_logic
	port map (reset => reset, clk => clk, 
		tick_i => '1',
		prn_o => prn_s, bit_o => bit_s);
	
	prn_presc : entity work.prn20b_presc
	generic map (CPT_SIZE => 32)
	port map (clk_i => clk, rst_i => reset,
		prescaler_i => x"0000000A",
		clk_gen_o => clk_gen_s,
		tick_o => tick_s
	);

	stimulis : process
	begin
	reset <= '1';
	wait until rising_edge(clk);
	reset <= '1';
	wait until rising_edge(clk);
	wait until rising_edge(clk);
	wait until rising_edge(clk);
	reset <= '0';
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
	--wait for 10 us;
	--wait for 10 us;
	--wait for 10 us;
	--wait for 10 us;
	--wait for 10 us;
	--wait for 10 us;
	--wait for 10 us;
	--wait for 10 us;
	--wait for 10 us;
	--wait for 10 us;
	--wait for 10 us;
	--wait for 10 us;
	--wait for 10 us;
	--wait for 10 us;
	--wait for 10 us;
	wait until rising_edge(clk);
	wait until rising_edge(clk);
	--wait for 1 ms;
	assert false report "End of test" severity error;
	end process stimulis;

	store_result : process(clk, reset)
--		use Std.TextIO.all;
--		use IEEE.Std_Logic_TextIO.all;
		variable lp: line;
		variable pv: Std_Logic;
	begin
		if (reset = '1') then
		elsif rising_edge(clk) then
			write(lp, integer'image(to_integer(unsigned(prn_s))));
			writeline(final_result_file, lp);
		end if;
	end process;
	
	clockp : process
	begin
		clk <= '1';
		wait for HALF_PERIOD;
		clk <= '0';
		wait for HALF_PERIOD;
	end process clockp;

end architecture RTL;
