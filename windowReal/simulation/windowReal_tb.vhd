library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
USE std.textio.ALL;
--use work.sp_vision_test_pkg.all;

entity windowReal_tb is
end entity windowReal_tb;

architecture RTL of windowReal_tb is
	function to_string(sv: Std_Logic_Vector) return string is
		use Std.TextIO.all;
		variable bv: bit_vector(sv'range) := to_bitvector(sv);
		variable lp: line;
	begin
		write(lp, bv);
		return lp.all;
	end;

	signal reset : std_logic;
   CONSTANT HALF_PERIODE : time := 5.0 ns;  -- Half clock period
	CONSTANT ADC_PERIOD : time := 2.5 ns;  -- Half clock period
	signal clk, adc_clk : std_logic;

	signal coeff_en_s : std_logic;
	signal coeff_val_s : std_logic_vector(15 downto 0);
	signal coeff_addr_s : std_logic_vector(9 downto 0);

	signal sl_clk_s, slow_clk : std_logic;
	signal generate_en_s : std_logic;


	-- data storage and propagation
	signal read_data_en_s : std_logic;
	signal read_data_val_s : std_logic_vector(15 downto 0);
	signal read_data_addr_s : std_logic_vector(9 downto 0);
	signal end_read_s, end_read2_s : std_logic;
	signal prop_data_addr_s : std_logic_vector(9 downto 0);
	signal prop_data_addr_nat_s : natural range 0 to 2**10-1;
    
	file final_result_file: text open write_mode is "./result.txt";
	
	-- new
	signal data_en_s : std_logic;
	signal data_s : std_logic_vector(15 downto 0);
	-- output result from fir
	signal result_s : std_logic_vector(31 downto 0);
	signal result_en_s : std_logic;

	constant NB_FIR : natural := 13;
	constant DECIMATE_FACTOR : natural := 10;
	--constant NB_FIR : natural := 32;
	--constant DECIMATE_FACTOR : natural := 4;
	constant NB_COEFF : natural := 128;

	signal tick_s : std_logic;
	constant MAX_CNT : natural := 100;
	signal cpt_delay_s : natural range 0 to MAX_CNT-1;
begin

	prop_data_addr_s <= std_logic_vector(to_unsigned(prop_data_addr_nat_s, 10));
	end_read_s <= '1' when (end_read2_s and generate_en_s) = '1' else '0';
	
	fir16 : Entity work.firRealSlow_ng_top
	generic map (
		coeff_format => "signed",
		NB_FIR => NB_FIR,
		DECIMATE_FACTOR => DECIMATE_FACTOR,
		NB_COEFF => NB_COEFF,
		DATA_IN_SIZE => 16,
		DATA_OUT_SIZE => 32
	)
	port map
	(
		-- Syscon signals
		processing_clk_i => adc_clk,
		reset	=> reset,
		clk => clk,
		-- coefficients
		coeff_data_i => coeff_val_s,
		coeff_addr_i => coeff_addr_s,
		coeff_en_i => coeff_en_s,
		-- input data
		data_i => data_s,
		data_en_i => data_en_s,
		-- for the next component
		data_o  => result_s,
		data_en_o => result_en_s
	);

	show_result : process(clk, reset)
		use Std.TextIO.all;
		use IEEE.Std_Logic_TextIO.all;
		variable lp: line;
		variable pv: Std_Logic;
	begin
		if reset = '1' then
		elsif rising_edge(clk) then
			if result_en_s = '1' then
				write(lp, string'("Value of i: "));
				write(lp, to_integer(unsigned(result_s)));
				writeline(Output, lp);
				--report "plop : "&integer'image(to_integer(unsigned(result_i_s))) severity note;
			end if;
		end if;
	end process;

	store_result : process(adc_clk, reset)
		use Std.TextIO.all;
		use IEEE.Std_Logic_TextIO.all;
		variable lp: line;
		variable pv: Std_Logic;
	begin
		if (reset = '1') then
		elsif rising_edge(adc_clk) then
			if (end_read_s and result_en_s) = '1' then
				write(lp, integer'image(to_integer(unsigned(result_s))));
				writeline(final_result_file, lp);
			end if;
		end if;
	end process; 

	process(adc_clk, reset)
	begin
		if reset = '1' then
			tick_s <= '0';
			cpt_delay_s <= 0;
		elsif rising_edge(adc_clk) then
			tick_s <= '0';
			cpt_delay_s <= cpt_delay_s;
			if end_read_s = '1' then
				if cpt_delay_s < MAX_CNT -1 then
					cpt_delay_s <= cpt_delay_s + 1;
				else
					cpt_delay_s <= 0;
					tick_s <= '1';
				end if;
			else
				cpt_delay_s <= 0;
			end if;
		end if;
	end process;


-- read data from a file and store this into a ram
-- TBD : must be read I and Q 
	read_data : entity work.readFromFile
	generic map(
		DATA_SIZE => 16,
		ADDR_SIZE => 10,
		filename =>
		"./datai.dat"
	)
	port map (
		reset => reset,
		clk => clk,
		sl_clk_i => sl_clk_s,
		--fichier => datas,
		start_read_i => '1',
		data_o => read_data_val_s,
		addr_o => read_data_addr_s,
		data_en_o => read_data_en_s,
		end_of_read_o => end_read2_s
	);
	
	ram_i : entity work.ram_storage16
	generic map(
		DATA => 16,
		ADDR => 10
	)
	port map (
		clk_a => clk,
		clk_b => adc_clk,
		reset => reset,
		-- input datas
		we_a => read_data_en_s,
		din_a => read_data_val_s,
		addr_a => read_data_addr_s,
		dout_a => open,
		-- output
		we_b => '0',
		addr_b => prop_data_addr_s,
		din_b => (15 downto 0 => '0'),
		dout_b => data_s
	);
	
	-- generate data flow
	data_propagation : process(adc_clk, reset)
	begin
		if (reset = '1') then
			prop_data_addr_nat_s <= 0;
			data_en_s <= '0';
		elsif rising_edge(adc_clk) then
			data_en_s <= '0';
			prop_data_addr_nat_s <= prop_data_addr_nat_s;
			if tick_s = '1' then
					if prop_data_addr_nat_s = 1023 then
						prop_data_addr_nat_s <= 0;
					else
						prop_data_addr_nat_s <= prop_data_addr_nat_s + 1;
					end if;
					data_en_s <= '1';
			end if;
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
	wait until generate_en_s='1';
	report "fin de la lecture de la LUT" severity note;
	wait until end_read_s='1';
	report "fin de la lecture des data" severity note;
    wait for 10 us;
    wait for 10 us;
    wait for 10 us;
    wait for 10 us;
    wait for 10 us;
    wait for 10 us;
    wait for 10 us;
    wait for 10 us;
    wait for 10 us;
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
    
	 clockadc : process
    begin
        adc_clk <= '1';
        wait for ADC_PERIOD;
        adc_clk <= '0';
        wait for ADC_PERIOD;
    end process clockadc;

	-- read coeff for fir16 LUT
	read_coeff : entity work.readFromFile
	generic map(
		DATA_SIZE => 16,
		ADDR_SIZE => 10,
		filename => "./fake_coeff.dat"
	)
	port map (
		reset => reset,
		clk => clk,
		sl_clk_i => sl_clk_s,
		--fichier => vectors,
		start_read_i => '1',
		data_o => coeff_val_s,
		addr_o => coeff_addr_s,
		data_en_o => coeff_en_s,
		end_of_read_o => generate_en_s
	);

	clk_divider : process(clk, reset)
		variable tt : natural range 0 to 1;
	begin
		if reset = '1' then
			sl_clk_s <= '0';
			tt := 0;
		elsif rising_edge(clk) then
			sl_clk_s <= '0';
			if tt = 1 then
				sl_clk_s <= '1';
				tt := 0;
			else
				tt := tt+1;
			end if;
		end if;
	end process;

end architecture RTL;
