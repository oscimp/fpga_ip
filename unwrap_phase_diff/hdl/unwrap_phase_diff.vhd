----------------------------------------------------------------------
-- (c) Copyright: OscillatorIMP Digital
-- Author : Ivan Ryger, ivan.ryger@femto-st.fr
-- Creation date : 2021/09/14
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
	        PI_VALUE		: integer := 12868;         --M_PI*2**(NB_ITER - 1)
        	FILTER_COEFF_TWOS_POWER : natural := 5;	-- determines the LP filter cutoff frequency 2*pi*fpole/fs=ln(1-2^(-N))
		ESTIMATION_METHOD 	: natural := 2  --0- simple phase extraction,
						  	--1-simple phase and frequency extraction,
	       						--2- robust extraction of phase and frequency   
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
	
    --constant rl2 : real := log(real(PI_VALUE))/log(2.0);
	constant PI_BIT_WIDTH		: integer := integer(round(log(real(PI_VALUE))/log(2.0)));
	constant INT_SIG_WIDTH		: natural := DATA_OUT_WIDTH;
	constant COEFF_WIDTH 		: natural :=  FILTER_COEFF_TWOS_POWER;
	constant INT_SIG_WIDTH_2	: natural := DATA_OUT_WIDTH + 2 * FILTER_COEFF_TWOS_POWER;
    
	signal ph1 : std_logic_vector(DATA_WIDTH - 1 downto 0);
	signal ph2, ph3, ph33, ph4, ph5, ph6, ph7, ph12, ph13, ph14 : std_logic_vector(INT_SIG_WIDTH - 1 downto 0);
   
	signal ph8, ph9, ph10 : std_logic_vector(INT_SIG_WIDTH_2 - 1 downto 0);
    	signal ph11 : std_logic_vector(INT_SIG_WIDTH_2 - 1 downto 0) := (others =>'0');
    	signal en_i_1, en_i_2, en_i_3 : std_logic;
begin
    -- cases
    simple_phase_unwrap :
    if ESTIMATION_METHOD = 0 generate
    	ph14 <= (others => '0'); --simple phase unwrap  
    end generate simple_phase_unwrap;
    
    phase_and_frequency_unwrap :
    if ESTIMATION_METHOD = 1 generate
    	ph14 <= ph13; --phase and frequency unwrap
    end generate phase_and_frequency_unwrap;
    
    robust_phase_and_frequency_unwrap :
    if ESTIMATION_METHOD = 2 generate
    	ph14 <= ph12; --robust phase and frequency unwrap
    end generate robust_phase_and_frequency_unwrap;
    
    data_clk_o <= data_clk_i;
    data_rst_o <= data_rst_i;
    
	enable_chain: process(data_clk_i) is
	begin
		if rising_edge(data_clk_i) then 
			if(data_rst_i = '1') then
				en_i_1 <= '0';
                en_i_2 <= '0';
                en_i_3 <= '0';
			else
				en_i_1 <= data_en_i;
                en_i_2 <= en_i_1;
                en_i_3 <= en_i_2;
			end if;
		end if;
	end process enable_chain;
    
    data_propagation: process (data_clk_i) is
	begin
		if rising_edge(data_clk_i) then
			if (data_rst_i = '1') then
				ph1 <= (others => '0');
			elsif(data_en_i = '1') then
				ph1<= data_in;
			else
				ph1<= ph1;
			end if;
			if (data_rst_i = '1') then
				ph2 <= (others => '0');
			elsif (en_i_1 = '1') then 
				ph2 <= std_logic_vector(resize(signed(ph1),ph2'length));
			else 
				ph2 <= ph2;
			end if;
            if (data_rst_i = '1') then
				ph3 <= (others => '0');
			elsif (en_i_1 = '1') then 
				ph3 <= ph33;
			else 
				ph3 <= ph3;
			end if;
           if (data_rst_i = '1') then
				ph11 <= (others => '0');
                ph13 <= (others => '0');
			elsif (en_i_3 = '1') then 
				ph11 <= ph10;
                ph13 <= ph7;
			else 
                ph11 <= ph11;
                ph13 <= ph13;
			end if;
		end if;
	end process data_propagation;

	ph33 <= std_logic_vector(signed(ph1) - signed(ph2));
	ph4 <= std_logic_vector(signed(ph14) - signed(ph3));

	-- perform rounding by adding 1/2 LSB
	ph5 <= std_logic_vector(shift_right(signed(ph4) + to_signed(2**(PI_BIT_WIDTH),ph4'length) , PI_BIT_WIDTH + 1));
	-- scale the result up
	--ph6 <= std_logic_vector(shift_left(signed(ph5),PI_INTERVAL_TWOS_POWER + 1));
    -- multiply by 2*pi
    ph6 <= std_logic_vector(shift_left(resize(signed(ph5) * to_signed(PI_VALUE,ph5'length),ph6'length),1));
    --ph6 <= std_logic_vector(shift_left(resize(signed(ph5) * to_signed(12867,ph5'length),ph6'length),0));
	ph7 <= std_logic_vector(signed(ph3) + signed(ph6));
  
    -- IIR lowpass filter  
    ph8 <= std_logic_vector(shift_left(resize(signed(ph7),INT_SIG_WIDTH_2),COEFF_WIDTH)); 
	ph9 <= std_logic_vector(signed(ph8) - signed(ph11));
	--we add 1/2 LSB to perform rounding instead of truncation - lower quantization noise
	ph10 <= std_logic_vector(shift_right(signed(ph9) + to_signed(2**(COEFF_WIDTH-1),ph9'length), COEFF_WIDTH) + signed(ph11));
	ph12 <= std_logic_vector(resize(shift_right(signed(ph11)+ to_signed(2**(COEFF_WIDTH-1),ph11'length) ,COEFF_WIDTH),ph12'length));

    data_en_o <= en_i_3;
    data_out <= ph7;
end bhv; 
