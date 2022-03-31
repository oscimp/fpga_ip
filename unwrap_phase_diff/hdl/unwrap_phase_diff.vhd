----------------------------------------------------------------------
-- (c) Copyright: OscillatorIMP Digital
-- Author : Ivan Ryger, ivan.ryger@femto-st.fr
-- Creation date : 2021/09/14
-- Modification  : 2022/01/27 IR rewritten logic of the unwrapping algorithm, fixed questionnable timing closure
-- Modification  : 2021/11/8, IR changed the input PI interval mapping for more general case:
-- current code accepts the PI interval not being strictly mapped to power of 2, but arbitrary integer interval;
-----------------------------------------------------------------------
-- idea of introducing inertia into instantaneous frequency estimation originally from
-- these Hugo Bergeron, Synthèse de fréquences optiques, Universite de Laval, 2016, p. 42-48

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity unwrap_phase_diff is
	generic(
		DATA_WIDTH 		: natural :=16;
		DATA_OUT_WIDTH 		: natural := 32;
		PI_VALUE		: integer := 12868;	--   M_PI*2**(NB_ITER - 1)
		FILTER_COEFF_TWOS_POWER : natural := 5;		--   determines the LP filter cutoff frequency 2*pi*fpole/fs=ln(1-2^(-N))
		ESTIMATION_METHOD 	: natural := 2  	-- 0 simple phase extraction,
						  		-- 1 simple phase and frequency extraction,
		   						-- 2 robust extraction of phase and frequency   
	);
	port(
		data_in		: in std_logic_vector(DATA_WIDTH - 1 downto 0);
		data_en_i	: in std_logic;
		data_clk_i	: in std_logic;
		data_rst_i	: in std_logic;
		data_out	: out std_logic_vector(DATA_OUT_WIDTH - 1 downto 0);
		data_en_o	: out std_logic;
		data_clk_o	: out std_logic;
		data_rst_o	: out std_logic
		);
end entity;
architecture bhv of unwrap_phase_diff is
	
	constant PI_BIT_WIDTH		: integer := integer(round(log(real(PI_VALUE))/log(2.0)));
	constant INT_SIG_WIDTH		: natural := DATA_OUT_WIDTH;
	constant COEFF_WIDTH 		: natural := FILTER_COEFF_TWOS_POWER;
	constant INT_SIG_WIDTH_2	: natural := DATA_OUT_WIDTH + 2 * FILTER_COEFF_TWOS_POWER;
	
	signal ph1_0, ph1_1 : std_logic_vector(DATA_WIDTH - 1 downto 0);
	signal ph2_0, ph2_1, ph2_2, ph2_3, ph3_0, ph3_2, ph4_0, ph4_2, ph4_3, ph7_0, ph8_0  : std_logic_vector(INT_SIG_WIDTH - 1 downto 0);
  
	signal ph5_0, ph6_0, ph6_2 : std_logic_vector(INT_SIG_WIDTH_2 - 1 downto 0);

	signal sel : std_logic_vector(1 downto 0);
	signal ph_threshold, ph_correction, ph_correction_3 : std_logic_vector(INT_SIG_WIDTH - 1 downto 0);
	signal ph_threshold_gt_zero, ph3_2_msb : std_logic;
	
	signal en_s_1, en_s_2, en_s_3 : std_logic;
begin
	-- cases
	simple_phase_unwrap :
	if ESTIMATION_METHOD = 0 generate
		ph8_0 <= (others => '0'); --simple phase unwrap  
	end generate simple_phase_unwrap;
	
	phase_and_frequency_unwrap :
	if ESTIMATION_METHOD = 1 generate
		ph8_0 <= ph4_2; --phase and frequency unwrap
	end generate phase_and_frequency_unwrap;
	
	robust_phase_and_frequency_unwrap :
	if ESTIMATION_METHOD = 2 generate
		ph8_0 <= ph7_0; --robust phase and frequency unwrap
	end generate robust_phase_and_frequency_unwrap;
	
	data_clk_o <= data_clk_i;
	data_rst_o <= data_rst_i;
	
	enable_chain: process(data_clk_i) is
	begin
	if rising_edge(data_clk_i) then 
		if(data_rst_i = '1') then
			en_s_1 <= '0';
			en_s_2 <= '0';
			en_s_3 <= '0';
		else
			en_s_1 <= data_en_i;
			en_s_2 <= en_s_1;
			en_s_3 <= en_s_2;
		end if;
	end if;
	end process enable_chain;
	
	data_propagation: process (data_clk_i) is
	begin
	if rising_edge(data_clk_i) then	
		
		if (data_rst_i = '1') then
			ph1_0 <= (others => '0');
		elsif(data_en_i = '1') then
			ph1_0 <= data_in;
		else
			ph1_0 <= ph1_0;
		end if;

		if (data_rst_i = '1') then
			ph1_1 <= (others => '0');
			ph2_1 <= (others => '0');
		elsif (en_s_1 = '1') then 
			ph1_1 <= ph1_0; 
			ph2_1 <= ph2_0;
		else 
			ph1_1 <= ph1_1;
			ph2_1 <= ph2_1;
		end if;

		if (data_rst_i = '1') then
			ph2_2 <= (others => '0');
			ph3_2 <= (others => '0');
			ph4_2 <= (others => '0');
			ph6_2 <= (others => '0');
		elsif (en_s_2 = '1') then 
			ph2_2 <= ph2_1;
			ph3_2 <= ph3_0;
			ph4_2 <= ph4_0;
			ph6_2 <= ph6_0;

		else 
			ph2_2 <= ph2_2;
			ph3_2 <= ph3_2;
			ph4_2 <= ph4_2;
			ph6_2 <= ph6_2;
		end if;

		if (data_rst_i = '1') then
			ph2_3 <= (others => '0');
 			ph4_3 <= (others => '0');
			ph_correction_3 <= (others => '0');
		elsif (en_s_3 = '1') then 
			ph2_3 <= ph2_2;
			ph4_3 <= ph4_0;
			ph_correction_3 <= ph_correction; 
		else 
			ph2_3 <= ph2_3;
			ph4_3 <= ph4_3;
			ph_correction_3 <= ph_correction_3;
		end if;

	end if;
	end process data_propagation;
	
	ph2_0 <= std_logic_vector(resize(signed(ph1_0) - signed(ph1_1),INT_SIG_WIDTH));
	ph3_0 <= std_logic_vector(signed(ph8_0) - signed(ph2_1));
	ph_threshold <= std_logic_vector(abs(signed(ph3_2)) - PI_VALUE);
	
 	-- non-sequential statement 'when' instead of 'if'
	ph_threshold_gt_zero <= '1' when (signed(ph_threshold) > 0) else '0'; -- find if the signal is above threshold
	ph3_2_msb <= ph3_2(INT_SIG_WIDTH - 1); -- find if the signal is negative

	sel <= ph_threshold_gt_zero & ph3_2_msb; -- concatenate selector conditions into std_logic_vector 
	
   	-- when (-1)*ph4_2 is negative (ph4_msb == 1), subtract 2*pi, else add 2*pi
   
	proc1: process(sel)
	begin
		case sel is 
 			when "11" =>   ph_correction <= std_logic_vector(to_signed(-2*PI_VALUE,INT_SIG_WIDTH));
	  		when "10" =>   ph_correction <= std_logic_vector(to_signed(2*PI_VALUE,INT_SIG_WIDTH));
  			when others => ph_correction <= std_logic_vector(to_signed(0,INT_SIG_WIDTH));
		end case;
	end process proc1;

	ph4_0 <= std_logic_vector(resize(signed(ph_correction_3) +  signed(ph2_3), INT_SIG_WIDTH)); 
	-- IIR lowpass filter  
	ph5_0 <= std_logic_vector(shift_left( resize(signed(ph4_3),INT_SIG_WIDTH_2) , COEFF_WIDTH) - signed(ph6_2)); 
	ph6_0 <= std_logic_vector(shift_right(signed(ph5_0),COEFF_WIDTH) + signed(ph6_2));
	ph7_0 <= std_logic_vector(resize(shift_right(signed(ph6_2),COEFF_WIDTH),INT_SIG_WIDTH));	

	data_en_o <= en_s_3;
	data_out <= ph4_3;
end bhv; 

