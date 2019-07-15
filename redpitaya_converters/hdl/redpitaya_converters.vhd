library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity redpitaya_converters is
generic (
	ADC_SIZE : natural := 14;
	ADC_EN : boolean := true;
	CLOCK_DUTY_CYCLE_STABILIZER_EN : boolean := false;
	DAC_EN : boolean := true
);
port (
	-- CANDR
	adc_rst_i       : in std_logic;
    clk_o           : out std_logic;
    rst_o           : out std_logic;
    rstn_o          : out std_logic;
	-- input diff clk
	adc_clk_p_i     : in std_logic;
	adc_clk_n_i     : in std_logic;
	-- adc
    --   phys - lvds/cmos input/output
    adc_data_a_i    : in std_logic_vector(ADC_SIZE-1 downto 0);
    adc_data_b_i    : in std_logic_vector(ADC_SIZE-1 downto 0);
    adc_cdcs        : out std_logic;
    --   adc data to design
    data_a_o        : out std_logic_vector(ADC_SIZE-1 downto 0);
    data_a_en_o     : out std_logic;
    data_a_clk_o    : out std_logic;
    data_a_rst_o    : out std_logic;
    data_b_o        : out std_logic_vector(ADC_SIZE-1 downto 0);
    data_b_en_o     : out std_logic;
    data_b_clk_o    : out std_logic;
    data_b_rst_o    : out std_logic;
	-- ad9767
	--  from design
	dac_dat_a_en_i  : in std_logic := '0';
	dac_dat_a_rst_i : in std_logic := '1';
	dac_dat_a_i     : in std_logic_vector(13 downto 0) := (others => '0');
	dac_dat_b_en_i  : in std_logic := '0';
	dac_dat_b_rst_i : in std_logic := '1';
	dac_dat_b_i     : in std_logic_vector(13 downto 0) := (others => '0');
	--  phys
	dac_dat_o       : out std_logic_vector(13 downto 0);
	dac_wrt_o       : out std_logic;
	dac_sel_o       : out std_logic;
	dac_clk_o       : out std_logic;
	dac_rst_o       : out std_logic
);
end entity redpitaya_converters;

architecture rtl of redpitaya_converters is

	component ad9767 is
	port (
		-- from design
		dac_dat_a_en_i  : in std_logic;
		dac_dat_a_rst_i : in std_logic;
		dac_dat_a_i     : in std_logic_vector(13 downto 0);
		dac_dat_b_en_i  : in std_logic;
		dac_dat_b_rst_i : in std_logic;
		dac_dat_b_i     : in std_logic_vector(13 downto 0);
		--  phys
		dac_dat_o       : out std_logic_vector(13 downto 0);
		dac_wrt_o       : out std_logic;
		dac_sel_o       : out std_logic;
		dac_clk_o       : out std_logic;
		dac_rst_o       : out std_logic;
		-- clk
		dac_clk_i       : in std_logic;
		dac_2clk_i      : in std_logic;
		dac_2ph_i       : in std_logic;
		dac_locked_i    : in std_logic
	);
	end component ad9767;

	signal dac_clk_s, dac_2clk_s : std_logic;
	signal dac_2ph_s, dac_locked_s : std_logic;

	component redpitaya_adc_dac_clk is
	port (
		adc_clk_p_i  : in std_logic;
		adc_clk_n_i  : in std_logic;
		adc_rst_i    : in std_logic;
		ser_clk_o    : out std_logic;
		-- dac
		dac_clk_o    : out std_logic;
		dac_2clk_o   : out std_logic;
		dac_2ph_o    : out std_logic;
		dac_locked_o : out std_logic;
		-- adc 
		adc_clk_o    : out std_logic;
		adc_rstn_o   : out std_logic;
		adc_rst_o    : out std_logic
	);
	end component redpitaya_adc_dac_clk;

	signal adc_clk_s  : std_logic;
	signal adc_rstn_s : std_logic;
	signal adc_rst_s  : std_logic;

	signal data_en_s : std_logic;
begin

	clk_o      <= adc_clk_s;
	rst_o      <= adc_rst_s;
	rstn_o     <= adc_rstn_s;

	redpitaya_clk: redpitaya_adc_dac_clk
	port map (
		adc_clk_p_i  => adc_clk_p_i,
		adc_clk_n_i  => adc_clk_n_i,
		adc_rst_i    => adc_rst_i,
		ser_clk_o    => open,
		dac_clk_o    => dac_clk_s,
		dac_2clk_o   => dac_2clk_s,
		dac_2ph_o    => dac_2ph_s,
		dac_locked_o => dac_locked_s,
		adc_clk_o    => adc_clk_s,
		adc_rstn_o   => adc_rstn_s,
		adc_rst_o    => adc_rst_s
	);

	disable_dac: if DAC_EN = false generate
		dac_dat_o <= (others => '0');
		dac_wrt_o <= '0';
		dac_sel_o <= '0';
		dac_clk_o <= '0';
		dac_rst_o <= '1';
	end generate disable_dac;

	enable_dac: if DAC_EN = true generate
		redpitaya_dac: ad9767
		port map (
			dac_dat_a_en_i  => dac_dat_a_en_i,
			dac_dat_a_rst_i => dac_dat_a_rst_i,
			dac_dat_a_i     => dac_dat_a_i,
			dac_dat_b_en_i  => dac_dat_b_en_i,
			dac_dat_b_rst_i => dac_dat_b_rst_i,
			dac_dat_b_i     => dac_dat_b_i,
			dac_dat_o       => dac_dat_o,
			dac_wrt_o       => dac_wrt_o,
			dac_sel_o       => dac_sel_o,
			dac_clk_o       => dac_clk_o,
			dac_rst_o       => dac_rst_o,
			-- clk
			dac_clk_i       => dac_clk_s,
			dac_2clk_i      => dac_2clk_s,
			dac_2ph_i       => dac_2ph_s,
			dac_locked_i    => dac_locked_s
		);
	end generate enable_dac;


	disable_adc: if ADC_EN = false generate
		data_a_o     <= (others => '0');
		data_a_en_o  <= '0';
		data_a_clk_o <= '0';
		data_a_rst_o <= '1';
		data_b_o     <= (others => '0');
		data_b_en_o  <= '0';
		data_b_clk_o <= '0';
		data_b_rst_o <= '1';

	end generate disable_adc;

	enable_adc: if ADC_EN = true generate
		data_a_en_o  <= data_en_s;
		data_a_clk_o <= adc_clk_s;
		data_a_rst_o <= adc_rst_s;

		data_b_en_o  <= data_en_s;
		data_b_clk_o <= adc_clk_s;
		data_b_rst_o <= adc_rst_s;

    	redpitaya_adc_capture_inst: entity work.redpitaya_adc_cmos_capture
		generic map (
			ADC_SIZE => ADC_SIZE,
			CLOCK_DUTY_CYCLE_STABILIZER_EN => CLOCK_DUTY_CYCLE_STABILIZER_EN
		)
    	port map (
			-- a/d
			clk_in_i     => adc_clk_s,
			resetn       => adc_rstn_s,
			clk_cdcs     => adc_cdcs,
			-- a/d a-b
			adc_data_a_i => adc_data_a_i,
			adc_data_b_i => adc_data_b_i,
			-- a/d dat
			adc_data_en  => data_en_s,
			adc_data_a   => data_a_o,
			adc_data_b   => data_b_o
		);
	end generate enable_adc;

end rtl;
