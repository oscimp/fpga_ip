library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
use IEEE.math_real.all;
USE std.textio.ALL;

entity top_xcorr_gps_slow_complex_tb is
end entity top_xcorr_gps_slow_complex_tb;

architecture RTL of top_xcorr_gps_slow_complex_tb is
	file final_result_file: text open write_mode is "./result.txt";

	signal reset : std_logic;
	CONSTANT HALF_PERIOD : time := 1.0 ns;  -- Half clock period
	signal clk : std_logic;

	constant IN_SIZE : natural := 16;
	constant OUT_SIZE : natural := 32;

	
	type data_tab is array (natural range <>) of std_logic_vector(IN_SIZE-1 downto 0);
    --signal truc_s : data_tab(31 downto 0) :=
    --    (others => (others => '0'));
	signal truc_s : std_logic;
	signal gold_code_s : std_logic_vector(31 downto 0);

	-- result
	signal data_en_s : std_logic;
	signal data_i_s, data_q_s : std_logic_vector(OUT_SIZE-1 downto 0);

	signal cpt_s : natural range 0 to 2048;
	signal stop_s :  std_logic;
	constant ACCUM_SIZE : natural := natural(ceil(log2(real(1023))));
	signal test_s : std_logic_vector(ACCUM_SIZE-1 downto 0);
	signal tick_s : std_logic;

	constant DELAY : natural := 16; --1023/70;
	signal cpt_delay_s : natural range 0 to DELAY-1;

	signal fake_data_s, fake_data2_s : std_logic_vector(IN_SIZE-1 downto 0);
	signal start_prod_s : std_logic;
	signal ext_rst_s : std_logic;

begin

	process(clk) begin
		if rising_edge(clk) then
			if reset = '1' then
				fake_data_s <= (others => '0');
				fake_data2_s <= (others => '0');
			elsif (start_prod_s and tick_s) = '1' then
				fake_data_s <= std_logic_vector(unsigned(fake_data_s) + 1);
				fake_data2_s <= fake_data_s;
			else
				fake_data_s <= fake_data_s;
				fake_data2_s <= fake_data_s;
			end if;
		end if;
	end process;

	cacode_inst : entity work.cacode
	port map (reset => reset, clk => clk, 
		tick_i => tick_s,
		g1_full_o => open, cacode_o => open,
		g1_o => open, g2_o => open,
		gold_code_o => gold_code_s);

	--gen_loop : for i in 0 to 31 generate
	--	truc_s(i) <= (IN_SIZE-1 downto 1 => '0') & gold_code_s(i);
	--end generate gen_loop;
	truc_s <= gold_code_s(0);

	xcorr_gps_slow_complex_inst : entity work.xcorr_gps_slow_complex
	generic map (NB_BLK=> 85,
		LENGTH => 1023, IN_SIZE => IN_SIZE, OUT_SIZE => OUT_SIZE)
	port map (data_rst_i => reset, data_clk_i => clk,
		ext_rst_i => ext_rst_s,
		data_en_i => tick_s, data_i_i => fake_data2_s, 
		data_q_i => fake_data2_s,
		prn_i => gold_code_s(0),
		data_clk_o => open, data_rst_o => open,
		data_en_o => data_en_s,
		data_i_o => data_i_s, data_q_o => data_q_s
	);

	--fake_data2_s <= truc_s(0);
	process(clk)
	begin
		if rising_edge(clk) then
			tick_s <= '0';
			if reset = '1' then
				cpt_delay_s <= 0;
			else
				if start_prod_s = '1' then
					if cpt_delay_s < DELAY-1 then
						cpt_delay_s <= cpt_delay_s + 1;
					else
						cpt_delay_s <= 0;
						tick_s <= '1';
					end if;
				else
					cpt_delay_s <= cpt_delay_s;
				end if;
			end if;
		end if;
	end process;

	process(clk)
	begin
		if rising_edge(clk) then
			stop_s <= '0';
			if reset = '1' then
				cpt_s <= 0;
			else
				cpt_s <= cpt_s;
				if data_en_s = '1' then
					--if (cpt_s < 100) then
					--if (cpt_s < 2048) then
					--if (cpt_s < 1024) then
						cpt_s <= cpt_s + 1;
						--assert true report integer'image(to_integer(cpt_s)) severity info;
					--else
					--	stop_s <= '1';
					--end if;
				end if;
			end if;
		end if;
	end process;
					
	
	stimulis : process
	begin
	reset <= '1';
	start_prod_s <= '1';
	ext_rst_s <= '1';
	wait until rising_edge(clk);
	reset <= '1';
	wait until rising_edge(clk);
	wait until rising_edge(clk);
	wait until rising_edge(clk);
	reset <= '0';
	wait until rising_edge(clk);
	ext_rst_s <= '0';
	wait until rising_edge(clk);
	start_prod_s <= '1';
	wait until rising_edge(clk);
	wait until rising_edge(clk);
	wait until rising_edge(clk);
	wait until rising_edge(clk);

	wait until rising_edge(data_en_s);
	wait until rising_edge(clk);
	wait until rising_edge(data_en_s);
	wait until rising_edge(clk);
	wait until rising_edge(data_en_s);
	start_prod_s <= '0';
	wait until rising_edge(clk);
	wait until rising_edge(clk);
	reset <= '1';
	wait until rising_edge(clk);
	wait until rising_edge(clk);
	wait until rising_edge(clk);
	reset <= '0';
	wait until rising_edge(clk);
	ext_rst_s <= '1';
	wait until rising_edge(clk);
	ext_rst_s <= '0';
	wait until rising_edge(clk);
	start_prod_s <= '1';
	wait until rising_edge(clk);


	wait for 10 ns;

	wait until rising_edge(clk);
	wait until rising_edge(clk);
	wait until rising_edge(stop_s);
	--wait until rising_edge(data_en_s);
	--wait until rising_edge(data_en_s);
	--wait until rising_edge(data_en_s);
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
		variable lp: line;
		variable pv: Std_Logic;
	begin
		if (reset = '1') then
		elsif rising_edge(clk) then
			if (data_en_s = '1') then
				write(lp, integer'image(to_integer(signed(data_i_s))));
				write(lp, string'(" "));
				write(lp, integer'image(to_integer(signed(data_q_s))));
				writeline(final_result_file, lp);
			end if;
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
