library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
USE std.textio.ALL;

entity top_nco_counter_tb is
end entity top_nco_counter_tb;

architecture RTL of top_nco_counter_tb is
	function to_string(sv: std_logic_vector) return string is
		use Std.TextIO.all;
		variable bv: bit_vector(sv'range) := to_bitvector(sv);
		variable lp: line;
	begin
		write(lp, bv);
		return lp.all;
	end;
	constant LUT_SIZE : natural := 12;
	constant COUNTER_SIZE : natural := 32;
	constant DATA_SIZE : natural := 14;

	signal reset : std_logic;
    CONSTANT HALF_PERIODE : time := 4 ns; --5.0 ns;  -- Half clock period
	signal clk : std_logic;

	signal cpt_step_s : std_logic_vector(COUNTER_SIZE-1 downto 0);
	signal cpt_tmp_s : std_logic_vector(COUNTER_SIZE-1 downto 0);

	signal reset_nco_s : std_logic;

	signal cos_fake_s, sin_fake_s, wave_en_s : std_logic;
	signal cos_s, sin_s : std_logic_vector(DATA_SIZE-1 downto 0);
	signal cos2_fake_s, sin2_fake_s, wave2_en_s : std_logic;
	signal cos2_s, sin2_s : std_logic_vector(DATA_SIZE-1 downto 0);
	signal cos3_fake_s, sin3_fake_s, wave3_en_s : std_logic;
	signal cos3_s, sin3_s : std_logic_vector(DATA_SIZE-1 downto 0);
	file final_result_file: text open write_mode is "./result.txt";
	file final2_result_file: text open write_mode is "./result2.txt";

	signal ready_store_s : std_logic;

	signal max_accum_s : std_logic_vector(COUNTER_SIZE-1 downto 0);
begin

	--cpt_step_s <= x"0A3D70A3";
	--cpt_tmp_s <= x"00000028";
	--cpt_tmp_s <= x"0A3D70A3";
	--cpt_tmp_s <= x"028F5C28";
	--cpt_tmp_s <= x"00001000";
	--cpt_tmp_s <=  x"147AE148";
	--cpt_tmp_s <=  x"0A3D70A4";
	cpt_tmp_s <=  x"40000000";
	max_accum_s<= x"00000019";
	cpt_step_s <= cpt_tmp_s(COUNTER_SIZE-1 downto 0);

	nco_inst : entity work.nco_counter_logic
	generic map(LUT_SIZE => LUT_SIZE, TEST => true,
		COUNTER_SIZE => COUNTER_SIZE, DATA_SIZE => DATA_SIZE,
		RESET_ACCUM=> false)
	port map(rst_i => reset, clk_i => clk, cpu_clk_i => '0',
		max_accum_i => max_accum_s,
		cpt_off_i => (LUT_SIZE-1 downto 0 => '0'),
		cpt_inc_i => cpt_step_s,
		test_o => open,
		cos_o => cos_s, sin_o => sin_s,
		cos_fake_o => cos_fake_s, sin_fake_o => sin_fake_s,
		wave_en_o => wave_en_s
	);

--	nco2_inst : entity work.nco_counter_logic
--	generic map(LUT_SIZE => LUT_SIZE, TEST => true,
--		COUNTER_SIZE => COUNTER_SIZE, DATA_SIZE => DATA_SIZE)
--	port map(rst_i => reset, clk_i => clk, cpu_clk_i => '0',
---		cpt_off_i => (LUT_SIZE-1 downto 0 => '0'),
--		cpt_step_i => cpt_tmp_s,
--		test_o => open,
--		cos_o => cos2_s, sin_o => sin2_s,
--		cos_fake_o => cos2_fake_s, sin_fake_o => sin2_fake_s,
--		wave_en_o => wave2_en_s
--	);
	--nco3_inst : entity work.nco_counter_logic
	--generic map(LUT_SIZE => 24,
--		COUNTER_SIZE => COUNTER_SIZE, DATA_SIZE => DATA_SIZE)
--	port map(rst_i => reset, clk_i => clk, cpu_clk_i => '0',
--		cpt_off_i => (24 downto 0 => '0'),
--		cpt_step_i => cpt_step_s,
--		test_o => open, step_scale_o => open,
--		cos_o => cos2_s, sin_o => sin2_s,
--		cos_fake_o => cos2_fake_s, sin_fake_o => sin2_fake_s,
--		wave_en_o => wave2_en_s
--	);

    stimulis : process
    begin
	ready_store_s <= '0';
	reset <= '0';
	wait until rising_edge(clk);
	reset <= '1';
	wait until rising_edge(clk);
	wait until rising_edge(clk);
	wait until rising_edge(clk);
	reset <= '0';
	wait until rising_edge(clk);
	ready_store_s <= '1';
	wait until rising_edge(clk);
    wait for 10 ns;
    wait for 10 us;
    wait for 10 us;
    wait for 10 us;
    wait for 10 us;
    wait for 10 us;
    wait for 10 us;
    wait for 10 us;
    wait for 10 us;
    wait for 10 us;
    wait for 10 ns;
    wait for 10 us;
    wait for 10 us;
    wait for 10 us;
    wait for 10 us;
    wait for 10 ns;
    wait for 10 us;
    wait for 10 us;
    --wait for 10 us;
    --wait for 10 us;
    --wait for 10 ns;
    --wait for 10 us;
    --wait for 10 us;
    --wait for 10 us;
    --wait for 10 us;
    --wait for 10 ns;
    --wait for 10 us;
    --wait for 10 us;
    --wait for 10 us;
    --wait for 10 us;
	--wait for 1 ms;
	--wait for 1 ms;
--	wait for 10 ms;
--   wait for 10 us;
--    wait for 10 us;
--    wait for 10 us;
--    wait for 10 us;
--    wait for 10 us;
--    wait for 10 us;
	wait for 1 ms;
    assert false report "End of test" severity error;
    end process stimulis;
    
    clockp : process
    begin
        clk <= '1';
        wait for HALF_PERIODE;
        clk <= '0';
        wait for HALF_PERIODE;
    end process clockp;


store_result : process(clk, reset)
	variable lp: line;
	variable pv: Std_Logic;
begin
	if (reset = '1') then
	elsif rising_edge(clk) then
		if ready_store_s = '1' then
			if wave_en_s = '1' then
				write(lp, integer'image(to_integer(signed(sin_s))));
				write(lp, string'(" "));
				write(lp, integer'image(to_integer(signed(cos_s))));
				writeline(final_result_file, lp);
			end if;
		end if;
	end if;
end process;

store_result2 : process(clk, reset)
	variable lp: line;
	variable pv: Std_Logic;
begin
	if (reset = '1') then
	elsif rising_edge(clk) then
		if ready_store_s = '1' then
			if wave2_en_s = '1' then
				write(lp, integer'image(to_integer(signed(sin2_s))));
				write(lp, string'(" "));
				write(lp, integer'image(to_integer(signed(cos2_s))));
				writeline(final2_result_file, lp);
			end if;
		end if;
	end if;
end process;


end architecture RTL;
