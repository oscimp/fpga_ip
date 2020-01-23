library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

entity top_dut is
	port (
		clk_i : in std_logic;
		rst_i : in std_logic;
		-- axistream
		M_AXIS_TVALID : out std_logic;
		M_AXIS_TDATA  : out std_logic_vector(32-1 downto 0);
		M_AXIS_TSTRB  : out std_logic_vector((32/8)-1 downto 0);
		M_AXIS_TLAST  : out std_logic;
		M_AXIS_TREADY : in std_logic;
		-- data in
		data1_i    : in std_logic_vector(31 downto 0);
		data2_i    : in std_logic_vector(31 downto 0);
		data_en_i  : in std_logic;
		data_eof_i : in std_logic;
		data_sof_i : in std_logic;
		-- config
		select_input_i      : in std_logic_vector(1 downto 0);
		start_acquisition_i : in std_logic;
		start_i             : in std_logic;
		prescaler_i         : in std_logic_vector(31 downto 0);
		update_presc_i      : in std_logic;
		trig_i              : in std_logic;
		dflt_val_i          : in std_logic_vector(31 downto 0);
		busy_o              : out std_logic;
		-- pulse delay
		period_cnt_i : std_logic_vector(31 downto 0);
		duty_cnt_i   : std_logic_vector(31 downto 0);
		enable_i     : std_logic
	);
end top_dut;

architecture Behavioral of top_dut is
	signal data1_s, data2_s : std_logic_vector(31 downto 0);
	signal data_en_s : std_logic;
	signal data_sof_s : std_logic;
	signal data_eof_s : std_logic;
	signal cpt_s : unsigned(31 DOWnto 0);
	signal delay_s : std_logic;
	signal mux_data1_s : std_logic_vector(31 downto 0);
	signal mux_data2_s : std_logic_vector(31 downto 0);
	signal mux_data_en_s : std_logic;
	signal mux_data_sof_s : std_logic;
	signal mux_data_eof_s : std_logic;

	signal gen_data_i_s, gen_data_q_s : std_logic_vector(31 downto 0);
	signal gen_data_en_s              : std_logic;
	signal gen_data_sof_s             : std_logic;
	signal gen_data_eof_s             : std_logic;

	signal pulse_s  : std_logic;
	signal trig_s   : std_logic;

	signal gen_data_i_d0_s : std_logic_vector(31 downto 0);
	signal gen_data_q_d0_s : std_logic_vector(31 downto 0);
	signal gen_data1_i_s, gen_data1_q_s : std_logic_vector(15 downto 0);
	signal gen_data2_i_s, gen_data2_q_s : std_logic_vector(15 downto 0);
	-- pulse gen
	signal pulse_trig_s : std_logic;
	signal pulse_data1_i_s, pulse_data1_q_s : std_logic_vector(15 downto 0);
	signal pulse_data2_i_s, pulse_data2_q_s : std_logic_vector(15 downto 0);
	signal pulse_data_en_s              : std_logic;
	signal pulse_data_sof_s             : std_logic;
	signal pulse_data_eof_s             : std_logic;

begin
	dut_inst : entity work.axi_dataComplex_dma_direct
	generic map (
		DATA_SIZE => 32,
		NB_SAMPLE => 10,
		C_M_AXIS_TDATA_WIDTH => 32
	)
	port map (
		clk => clk_i, reset => rst_i,
		M_AXIS_TVALID => M_AXIS_TVALID,
		M_AXIS_TDATA  => M_AXIS_TDATA,
		M_AXIS_TSTRB  => M_AXIS_TSTRB,
		M_AXIS_TLAST  => M_AXIS_TLAST,
		M_AXIS_TREADY => M_AXIS_TREADY,

		start_acquisition_i => start_acquisition_i,
		busy_o     => busy_o,
		data_en_i  => mux_data_en_s,
		data_sof_i => mux_data_sof_s,
		data_eof_i => mux_data_eof_s,
		data1_i    => mux_data1_s,
		data2_i    => mux_data2_s
	);

	process(select_input_i,
				data1_i, data2_i, data_en_i, data_sof_i, data_eof_i,
				data1_s, data2_s, data_en_s, data_sof_s, data_eof_s,
				gen_data_i_s, gen_data_q_s, gen_data_en_s, gen_data_sof_s, gen_data_eof_s
				) begin
		if (select_input_i = "00") then
			mux_data1_s <= data1_i;
			mux_data2_s <= data2_i;
			mux_data_en_s <= data_en_i;
			mux_data_sof_s <= data_sof_i;
			mux_data_eof_s <= data_eof_i;
		elsif select_input_i = "01" then
			mux_data1_s <= data1_s;
			mux_data2_s <= data2_s;
			mux_data_en_s <= data_en_s;
			mux_data_sof_s <= data_sof_s;
			mux_data_eof_s <= data_eof_s;
		elsif select_input_i = "10" then
			mux_data1_s <= pulse_data1_q_s & pulse_data1_i_s; 
			mux_data2_s <= pulse_data2_q_s & pulse_data2_i_s; 
			mux_data_en_s <= pulse_data_en_s;
			mux_data_sof_s <= pulse_data_sof_s;
			mux_data_eof_s <= pulse_data_eof_s;
		else
			mux_data1_s <= gen_data_i_d0_s;
			mux_data2_s <= gen_data_q_d0_s;
			mux_data_en_s <= gen_data_en_s;
			mux_data_sof_s <= gen_data_sof_s;
			mux_data_eof_s <= gen_data_eof_s;
		end if;
	end process;

	gen_data_i_d0_s <= gen_data_i_s;
	gen_data_q_d0_s <= std_logic_vector(unsigned(gen_data_q_s) + 10);

	process(pulse_s, pulse_trig_s, select_input_i, trig_i) begin
		if select_input_i = "11" then
			trig_s <= pulse_s;
		elsif select_input_i = "10" then
			trig_s <= pulse_trig_s;
		else
			trig_s <= pulse_s;
		end if;
	end process;

	process(clk_i) begin
		if rising_edge(clk_i) then
			if select_input_i /= "01" then
				delay_s <= '0';
				cpt_s <= (others => '0');
				data1_s <= (others => '0');
				data2_s <= (others => '0');
				data_en_s <= '0';
				data_sof_s <= '0';
				data_eof_s <= '0';
			elsif delay_s = '0' then
				delay_s <= '1';
				data1_s <= std_logic_vector(cpt_s + 1);
				data2_s <= std_logic_vector(cpt_s + 11);
				cpt_s <= cpt_s + 1;
				data_en_s <= '1';
				if cpt_s = 0 then
					data_sof_s <= '1';
				else
					data_sof_s <= '0';
				end if;
				if cpt_s = 9 then
					data_eof_s <= '1';
				else
					data_eof_s <= '0';
				end if;
			else
				delay_s <= '0';
				data1_s <= data1_s;
				data2_s <= data2_s;
				cpt_s <= cpt_s;
				data_en_s <= '0';
				data_sof_s <= '0';
				data_eof_s <= '0';
			end if;
		end if;
	end process;

	pseudoGenInst: entity work.pseudo_gen_trig_logic
	generic map (
		NB_SAMPLE  => 10,
		PRESC_SIZE => 32,
		DATA_SIZE  => 32
	)
	port map (
		clk         => clk_i,
		reset       => rst_i,
		trig_i      => trig_s,
		update_presc_i => update_presc_i,
		prescaler_i => prescaler_i,
		dflt_val_i  => dflt_val_i,
		start_i     => start_i,
		data_en_o   => gen_data_en_s,
		data_sof_o  => gen_data_sof_s,
		data_eof_o  => gen_data_eof_s,
		data_i_o    => gen_data_i_s,
		data_q_o    => gen_data_q_s
	);

	gen_data1_i_s <= gen_data_i_d0_s(15 downto 0);
	gen_data1_q_s <= gen_data_q_d0_s(15 downto 0);
	gen_data2_i_s <= std_logic_vector(unsigned(gen_data_i_d0_s(15 downto 0))+100);
	gen_data2_q_s <= std_logic_vector(unsigned(gen_data_q_d0_s(15 downto 0))+100);

	pulse_logic_inst : entity work.genPulseTwoWayCplx_logic
	generic map (
		USE_EXT_TRIG => true,
		GEN_SIZE => 32,
		DATA_SIZE => 16,
		NB_SAMPLE => 10 
	)
	port map(
		reset       => rst_i,
		clk         => clk_i,
		-- pulse
		ext_trig_i  => pulse_s,
		pulse_o     => pulse_trig_s,
		-- configuration
		period_cnt_i => (31 downto 0 => '0'),
		duty_cnt_i  => (31 downto 0 => '0'),
		enable_i    => start_i,
		-- input
		data_en_i   => gen_data_en_s,
		data1_i_i   => gen_data1_i_s,
		data1_q_i   => gen_data1_q_s,
		data2_i_i   => gen_data2_i_s(15 downto 0),
		data2_q_i   => gen_data2_q_s(15 downto 0),
		-- output
		data1_i_o   => pulse_data1_i_s,
		data1_q_o   => pulse_data1_q_s,
		data2_i_o   => pulse_data2_i_s,
		data2_q_o   => pulse_data2_q_s,
		data_en_o   => pulse_data_en_s,
		data_sof_o  => pulse_data_sof_s,
		data_eof_o  => pulse_data_eof_s
	);


	gr_logic_inst : entity work.pulseGenDelayed_logic
	generic map (
		GEN_SIZE  => 32
	)
	port map (
		reset        => rst_i,
		clk          => clk_i,
		pulse_o      => pulse_s,
		period_cnt_i => period_cnt_i,
		duty_cnt_i   => duty_cnt_i,
		enable_i     => enable_i
	);


end Behavioral;
