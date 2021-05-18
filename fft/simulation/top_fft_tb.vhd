library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
USE std.textio.ALL;
--use work.sp_vision_test_pkg.all;

entity top_fft_tb is
end entity top_fft_tb;

architecture RTL of top_fft_tb is
	constant DATA_SIZE : natural := 29;
	constant COEFF_SIZE : natural := 18;
	constant DATA_OUT_SIZE : natural := 40;
	constant ADDR_SIZE : natural := 12;
	constant COEFF_ADDR_SIZE : natural := 11;
	constant FFT_SIZE : natural := 11;
	constant DATA_STORE_SIZE : natural := 32;

	signal reset : std_logic;
	CONSTANT HALF_PERIODE : time := 5.0 ns;  -- Half clock period
	CONSTANT ADC_PERIOD : time := 2.5 ns;  -- Half clock period
	signal clk, adc_clk : std_logic;
	signal start_prod : std_logic;

	-- fft
	signal data_in_s : std_logic_vector(DATA_SIZE-1 downto 0);
	signal data_in_en_s : std_logic;
	signal coeff_re_s, coeff_im_s : std_logic_vector(COEFF_SIZE-1 downto 0);
	signal coeff_addr_s : std_logic_vector(COEFF_ADDR_SIZE-1 downto 0);
	signal coeff_en_s : std_logic;
	-- output data from FFT
	signal res_re_s, res_im_s : std_logic_vector(DATA_OUT_SIZE-1 downto 0);
	signal res_en_s, res_eof_s : std_logic;
	signal res_scale_re_s, res_scale_im_s : std_logic_vector(DATA_STORE_SIZE-1 downto 0);

	-- generator
	signal ram_addr_s : std_logic_vector(ADDR_SIZE-1 downto 0);
	signal tmp_data_s : std_logic_vector(DATA_SIZE-1 downto 0);
	signal cpt_s : natural range 0 to 2**ADDR_SIZE;
	-- read from file
	signal end_coeff_s, end_read_s : std_logic;
	signal read_data_en_s : std_logic;
	signal read_data_val_s : std_logic_vector(DATA_SIZE-1 downto 0);
	signal read_data_addr_s : std_logic_vector(ADDR_SIZE-1 downto 0);
	-- storage
	file final_result_file: text open write_mode is "./result.txt";
	signal rst_2, reset_transfert : std_logic;
	signal start_acq : std_logic;
	constant MAX_VAL : natural := 2;
	signal prescaler_s : natural range 0 to MAX_VAL-1;
	signal tick_s : std_logic;
	type gen_type is (IDLE, PROPAGATE, WAIT_END);
	signal state_s : gen_type;
	signal cpt2_s : natural range 0 to 2**FFT_SIZE;
	signal plop_s : std_logic;
begin
	rst_2 <= reset or reset_transfert;

	res_scale_re_s <= res_re_s(DATA_STORE_SIZE-1 downto 0);
	res_scale_im_s <= res_im_s(DATA_STORE_SIZE-1 downto 0);

	fft_inst : entity work.fft_top_logic
    generic map (
		USE_EOF => false,
		USE_FIRST_BUFF => false,
		USE_SEC_BUFF => false,
		DEBUG => false,
		LOG_2_N_FFT => FFT_SIZE, N_FFT => 2**FFT_SIZE,
		COEFF_SIZE => COEFF_SIZE,
		SHIFT_VAL => COEFF_SIZE-2,
        ADDR_SIZE => COEFF_ADDR_SIZE, DATA_IN_SIZE => DATA_SIZE,
		DATA_SIZE => DATA_OUT_SIZE)
    port map (clk_i => clk, cpu_clk_i => clk,
		cpu_rst_i => reset, data_rst_i => reset,
        -- input data
        data_i => data_in_s,
        data_en_i  => data_in_en_s,
		data_eof_i => '0',
        --configuration
		read_coeff_re_o => open,
		read_coeff_im_o => open,
        coeff_re_i => coeff_re_s,
        coeff_im_i => coeff_im_s,
        coeff_re_addr_i => coeff_addr_s,
        coeff_im_addr_i => coeff_addr_s,
        coeff_re_en_i => coeff_en_s,
        coeff_im_en_i => coeff_en_s,
        res_re_o => res_re_s, 
        res_im_o => res_im_s,
        res_en_o  => res_en_s,
		res_eof_o => res_eof_s);

	timer_proc : process(clk)
	begin
		if rising_edge(clk) then
			if rst_2 = '1' then
				tick_s <= '0';
				prescaler_s <= 0;
			else
				if prescaler_s < MAX_VAL-1 then
					prescaler_s <= prescaler_s + 1;
					tick_s <= '0';
				else
					prescaler_s <= 0;
					tick_s <= '1';
				end if;
			end if;
		end if;
	end process;

	-- generate data flow
	data_propagation : process(clk, rst_2)
	begin
		if (rst_2 = '1') then
			--data_in_s <= (DATA_SIZE-1 downto 0 => '0');
			data_in_en_s <= '0';
			cpt_s <= 0;
			ram_addr_s <= (others => '0');
			state_s <= IDLE;
			cpt2_s <= 0;
			plop_s <= '0';
		elsif rising_edge(clk) then
			data_in_en_s <= '0';
			cpt_s <= cpt_s;
			cpt2_s <= cpt2_s;
			ram_addr_s <= ram_addr_s;
			state_s <= state_s;
			plop_s <= plop_s;
			case state_s is 
			when IDLE =>
				if (end_coeff_s and end_read_s) = '1' then
					state_s <= PROPAGATE;
					cpt2_s <= 0;
				end if;
			when PROPAGATE =>
				if cpt2_s = 2**FFT_SIZE-1 then
					state_s <= WAIT_END;
					cpt2_s <= 0;
					plop_s <= '1';
				else
					cpt2_s <= cpt2_s + 1;
				end if;
				if cpt_s < 2**ADDR_SIZE then
					data_in_en_s <= '1';
					cpt_s <= cpt_s + 1;
					ram_addr_s <= std_logic_vector(unsigned(ram_addr_s) + 1);
				else
					cpt_s <= 0;
					ram_addr_s <= (others => '0');
				end if;
			when WAIT_END =>
				if res_eof_s = '1' then
					state_s <= PROPAGATE;
					cpt2_s <= 0;
					plop_s <= '0';
				end if;
			when others =>
			end case;
		end if;
	end process; 
				data_in_s <= tmp_data_s;

    stimulis : process
    begin
	start_acq <= '0';
	start_prod <= '0';
	reset_transfert <= '0';
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
	start_prod <= '1';
	start_acq <= '1';
	wait until end_coeff_s = '1';
	report "end_coeff_s" severity note;
	wait until end_read_s = '1';
	report "end_read_s" severity note;
	wait until plop_s = '1';
	wait until res_eof_s = '1';
	report "first" severity note;
	wait until res_eof_s = '1';
	report "second" severity note;
	--wait until res_eof_s = '1';
	--report "third" severity note;
	--wait until res_eof_s = '1';
	wait until rising_edge(clk);
	wait until rising_edge(clk);
	--wait until end_read_s = '1';
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

    read_coeff : entity work.readComplexFromFile
    generic map(DATA_SIZE => COEFF_SIZE, ADDR_SIZE => COEFF_ADDR_SIZE,
        filename_re => "../gen_data/coeff_re.dat",
        filename_im => "../gen_data/coeff_im.dat")
    port map (reset => reset, clk => clk, sl_clk_i => clk,
        --fichier => datas,
        start_read_i => '1',
        data_re_o => coeff_re_s,
        data_im_o => coeff_im_s,
        addr_o => coeff_addr_s,
        data_en_o => coeff_en_s,
        end_of_read_o => end_coeff_s);

    read_data : entity work.readFromFile
	generic map(DATA_SIZE => DATA_SIZE, ADDR_SIZE => ADDR_SIZE,
        --filename => "./gen_data/data.dat")
        filename => "../out_hanning2p20.dat")
    port map (reset => reset, clk => clk, sl_clk_i => clk,
        --fichier => datas,
        start_read_i => '1',
        data_o => read_data_val_s,
        addr_o => read_data_addr_s,
        data_en_o => read_data_en_s,
        end_of_read_o => end_read_s
	);

   ram_data : entity work.ram_storage16
    generic map(DATA => DATA_SIZE, ADDR => ADDR_SIZE)
    port map (clk_a => clk, clk_b => clk, reset => reset,
        -- input datas
        we_a => read_data_en_s,
        din_a => read_data_val_s,
        addr_a => read_data_addr_s,
        dout_a => open,
        -- output
        we_b => '0',
        addr_b => ram_addr_s,
        din_b => (DATA_SIZE-1 downto 0 => '0'),
        dout_b => tmp_data_s);

    store_result : process(clk)
        variable lp: line;
        variable pv: std_logic;
		variable int_val: integer;-- range -(2**DATA_OUT_SIZE)-1 to
    begin
        if rising_edge(clk) then
			if start_acq = '1' then
            	if res_en_s = '1' then
					--int_val := to_integer(signed(res_re_s));
					--write(lp, integer'image(int_val));
					write(lp, integer'image(to_integer(signed(res_scale_re_s))));
            	    write(lp, string'(" "));
					--int_val := to_integer(signed(res_im_s));
					write(lp, integer'image(to_integer(signed(res_scale_im_s))));
            	    writeline(final_result_file, lp);
            	end if;
			end if;
        end if;
    end process;



end architecture RTL;
