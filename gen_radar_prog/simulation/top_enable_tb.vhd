library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
USE std.textio.ALL;
--use work.sp_vision_test_pkg.all;

entity top_enable_tb is
end entity top_enable_tb;

architecture RTL of top_enable_tb is

	signal reset : std_logic;
	CONSTANT HALF_PERIODE : time := 5.0 ns;  -- Half clock period
	CONSTANT ADC_PERIOD : time := 2.5 ns;  -- Half clock period
	signal clk, adc_clk : std_logic;

	-- new
	signal data_en_s : std_logic;
	signal data_i_s, data_q_s : std_logic_vector(15 downto 0);
	-- output result from fir
	signal result_i_s, result_q_s : std_logic_vector(15 downto 0);
	signal result_en_s, result_eof_s : std_logic;
	signal result2_i_s, result2_q_s : std_logic_vector(15 downto 0);
	signal result2_en_s : std_logic;
	signal switch_s : std_logic;
	signal switchn_s : std_logic;
begin


	generateur: Entity work.gen_radar_prog_logic
	generic map (
		DATA_SIZE => 16,
		BURST_SIZE => 16
	)
	port map
	(
		-- Syscon signals
		reset	=> reset,
		clk => adc_clk,
		switch_o => switch_s,
		switchn_o => switchn_s,
		--axi
        rxoff_i     => x"0002",
        txon_i      => x"0008",
        point_period_i => x"0400",
		-- input data
		data_i_i => data_i_s,
		data_q_i => data_q_s,
		data_en_i => data_en_s,
		-- for the next component
		data_q_o  => result_q_s,
		data_i_o  => result_i_s,
		data_eof_o => result_eof_s,
		data_en_o => result_en_s
	);

--	point_inst: Entity work.extract_data_from_rafale
--	generic map (
--		DATA_SIZE => 16,
--		POINT_POS => 8
--	)
--	port map
--	(
--		-- Syscon signals
--		reset	=> reset,
--		clk => adc_clk,
--		-- input data
--		data_i_i => result_i_s,
--		data_q_i => result_q_s,
--		data_eof_i => result_eof_s,
--		data_en_i => result_en_s,
--		-- for the next component
--		data_q_o  => result2_q_s,
--		data_i_o  => result2_i_s,
--		data_en_o => result2_en_s
--	);

	-- generate data flow
	data_propagation : process(adc_clk, reset)
	begin
		if (reset = '1') then
			data_i_s <= (others => '0');
			data_q_s <= (others => '0');
			data_en_s <= '0';
		elsif rising_edge(adc_clk) then
			data_i_s <= std_logic_vector(unsigned(data_i_s)+1);
			data_q_s <= std_logic_vector(unsigned(data_q_s)+1);
			data_en_s <= '1';
		end if;
	end process; 

    stimulis : process
    begin
	reset <= '0';
	wait until rising_edge(clk);
	reset <= '1';
	wait until rising_edge(clk);
	wait until rising_edge(clk);
	wait until rising_edge(clk);
	reset <= '0';
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
    
	clockadc : process
    begin
        adc_clk <= '1';
        wait for ADC_PERIOD;
        adc_clk <= '0';
        wait for ADC_PERIOD;
    end process clockadc;

end architecture RTL;
