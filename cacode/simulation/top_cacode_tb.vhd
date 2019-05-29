library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
USE std.textio.ALL;

entity top_cacode_tb is
end entity top_cacode_tb;

architecture RTL of top_cacode_tb is
	file final_result_file: text open write_mode is "./result.txt";

	signal reset : std_logic;
	CONSTANT HALF_PERIOD : time := 5.0 ns;  -- Half clock period
	signal clk : std_logic;
	
	signal g1_s, g2_s : std_logic;
	signal g1_full_s, cacode_s : std_logic_vector(9 downto 0);

	signal clk_gen_s, tick_s : std_logic;

	type data_tab is array (natural range <>) of std_logic_vector(9 downto 0);
    signal truc_s : data_tab(31 downto 0) :=
        (others => (others => '0'));
	signal gold_code_s : std_logic_vector(31 downto 0);

	--signal truc_s : std_logic_vector(9 downto 0);
begin
--	truc_s(0) <= (9 downto 1 => '0') & gold_code_s(0);
--	truc_s(1) <= (9 downto 1 => '0') & gold_code_s(1);

--	cacode_inst : entity work.cacode
--	generic map (id=> 1)
--	port map (reset => reset, clk => clk, 
--		tick_i => '1',
--		cacode_o => cacode_s, g1_full_o => g1_full_s,
--		g1_o => g1_s, g2_o => g2_s,
--		gold_code_o => gold_code_s(0));

	cacode1_inst : entity work.cacode
	port map (reset => reset, clk => clk, 
		tick_i => '1',
		cacode_o => open, g1_full_o => open,
		g1_o => open, g2_o => open,
		gold_code_o => gold_code_s);

	gen_loop : for i in 0 to 31 generate
		truc_s(i) <= (9 downto 1 => '0') & gold_code_s(i);
	end generate gen_loop;
	
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
			--write(lp, integer'image(to_integer(unsigned(g1_full_s))));
            --write(lp, string'(" "));
			--write(lp, integer'image(to_integer(unsigned(cacode_s))));
			int_loop : for i in 0 to 31 loop
			write(lp, integer'image(to_integer(unsigned(truc_s(i)))));
            write(lp, string'(" "));
			end loop int_loop;
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
