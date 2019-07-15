library IEEE;
use IEEE.std_logic_1164.all;
library UNISIM;
use UNISIM.vcomponents.all;

entity redpitaya_adc_cmos_capture is
generic (
	ADC_SIZE : natural := 14;
	CLOCK_DUTY_CYCLE_STABILIZER_EN : boolean := false
);
port (
    -- redpitaya_adc
    clk_in_i: in std_logic;
    resetn: in std_logic;
    clk_cdcs: out std_logic;
    -- a/d cmos
    adc_data_a_i: in std_logic_vector(ADC_SIZE-1 downto 0);
    adc_data_b_i: in std_logic_vector(ADC_SIZE-1 downto 0);
    -- adc dat
    adc_data_en: out std_logic;
    adc_data_a: out std_logic_vector(ADC_SIZE-1 downto 0);
    adc_data_b: out std_logic_vector(ADC_SIZE-1 downto 0)
);
end entity redpitaya_adc_cmos_capture;

architecture rtl of redpitaya_adc_cmos_capture is

    signal data_a_s, data_b_s: std_logic_vector(ADC_SIZE-1 downto 0);
begin

    adc_data_a <= data_a_s;
    adc_data_b <= data_b_s;
	--dis_cdcs: if CLOCK_DUTY_CYCLE_STABILIZER_EN = false generate
    	clk_cdcs <= '0'; --'1';
	--end generate dis_cdcs;
	--en_cdcs: if CLOCK_DUTY_CYCLE_STABILIZER_EN /= false generate
    --	clk_cdcs <= '1';
	--end generate en_cdcs;
    
    latch_d: process(clk_in_i, resetn)
    begin
    	if resetn = '0' then
			adc_data_en <= '0';
			data_a_s <= (others => '0');
			data_b_s <= (others => '0');
	    elsif rising_edge(clk_in_i) then
			adc_data_en <= '1';
			data_a_s <= adc_data_a_i(ADC_SIZE-1)&not(adc_data_a_i(ADC_SIZE-2 downto 0));
			data_b_s <= adc_data_b_i(ADC_SIZE-1)&not(adc_data_b_i(ADC_SIZE-2 downto 0));
    	end if;
    end process latch_d;

end rtl;
