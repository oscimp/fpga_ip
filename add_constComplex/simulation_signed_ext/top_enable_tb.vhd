library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
USE std.textio.ALL;
--use work.sp_vision_test_pkg.all;

entity top_enable_tb is
end entity top_enable_tb;

architecture RTL of top_enable_tb is
	constant DATA_SIZE : natural := 14;

	signal reset : std_logic;
	CONSTANT HALF_PERIODE : time := 5.0 ns;  -- Half clock period
	CONSTANT ADC_PERIOD : time := 2.5 ns;  -- Half clock period
	signal clk, adc_clk : std_logic;

	-- new
	signal data_in_en_s, data_out_en_s : std_logic;
	signal data_in_s, data_out_s : std_logic_vector(DATA_SIZE-1 downto 0);
	-- output result from fir
	signal data_en_s : std_logic;
	signal end_state_s : std_logic;
	signal ram_data_s : std_logic_vector(DATA_SIZE-1 downto 0);
	signal enable_flow_s : std_logic;
	constant SL_MAX : natural := 1;
	signal slow_clk : natural range 0 to SL_MAX-1;
	signal tick_s : std_logic;
	signal start_prod : std_logic;
	--signal a_s, b_s : std_logic_vector(DATA_SIZE-1 downto 0);
	constant MAX_CNT : natural := 2**DATA_SIZE-1;
	signal cpt_s : natural range 0 to MAX_CNT-1;
begin

	process(clk, reset)
	begin
		if (reset = '1') then
			slow_clk <= 0;
			tick_s <= '0';
		elsif rising_edge(clk) then
			tick_s <= '0';
			if slow_clk < SL_MAX-1 then
				slow_clk <= slow_clk+1;
			else
				slow_clk <= 0;
				tick_s <= '1';
			end if;
		end if;
	end process;

	mult_const_inst : Entity work.add_const
	generic map (
		format => "signed",
		add_val => -8192,
		DATA_OUT_SIZE => DATA_SIZE,
		DATA_IN_SIZE => DATA_SIZE
	)
	port map (
		-- Syscon signals
		processing_rst_i	=> reset,
		processing_clk_i	=> clk,
		-- input data
		data_i				=> ram_data_s,--data_in_s,
		data_en_i			=> data_en_s,--data_in_en_s,
		-- for the next component
		data_o				=> data_out_s,		
		data_en_o			=> data_out_en_s
	);

	-- generate data flow
	data_propagation : process(clk, reset)
	begin
		if (reset = '1') then
			ram_data_s <= (DATA_SIZE-1 downto 0 => '0');
			data_en_s <= '0';
			cpt_s <= 0;
			--data_in_s <= x"1fff";
		elsif rising_edge(clk) then
			data_in_en_s <= '1';
			cpt_s <= cpt_s;
			data_en_s <= '0';
			ram_data_s <= ram_data_s;
			if start_prod = '1' then
				if tick_s = '1' then
					if cpt_s < MAX_CNT-1 then
						cpt_s <= cpt_s + 1;
					else
						cpt_s <= 0;
					end if;

					ram_data_s <= std_logic_vector(to_unsigned(cpt_s, DATA_SIZE)); 
					data_en_s <= '1';
				end if;
			end if;
		end if;
	end process; 

    stimulis : process
    begin
	start_prod <= '0';
	enable_flow_s <= '0';
	reset <= '0';
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
	enable_flow_s <= '1';
	wait until rising_edge(clk);
	start_prod <= '1';
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
