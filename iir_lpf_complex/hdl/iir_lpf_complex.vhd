-----------------------------------------------------------------------
-- (c) Copyright: OscillatorIMP Digital
-- Author : Ivan Ryger, ivan.ryger@femto-st.fr
-- Creation date : 2021/10/28
-----------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity iir_lpf_complex is 
	generic(
		DATA_WIDTH : natural := 16;
		FILTER_COEFF_TWOS_POWER : natural := 10 
		);
	port(
	       	data_i_i 	: in std_logic_vector(DATA_WIDTH-1 downto 0);
		data_q_i	: in std_logic_vector(DATA_WIDTH-1 downto 0);
		data_en_i 	: in std_logic;
		data_clk_i	: in std_logic;
		data_rst_i	: in std_logic;
		data_i_o 	: out std_logic_vector(DATA_WIDTH-1 downto 0);
		data_q_o 	: out std_logic_vector(DATA_WIDTH-1 downto 0);
		data_en_o	: out std_logic;
		data_clk_o  	: out std_logic;
		data_rst_o  	: out std_logic
		);
end entity;
architecture bhv of iir_lpf_complex is
--recursive filter implementation with transfer function 
-- H(z) = 2^(-N)*z^(-1)/(1-(1-2^-N)*z^(-1))
	constant INT_SIG_WIDTH : natural := DATA_WIDTH + 2 * FILTER_COEFF_TWOS_POWER;
	constant COEFF_WIDTH : natural := FILTER_COEFF_TWOS_POWER;
	signal data_i_1,data_i_4 : std_logic_vector(INT_SIG_WIDTH - 1 downto 0) := (others => '0');
	signal data_q_1,data_q_4 : std_logic_vector(INT_SIG_WIDTH - 1 downto 0) := (others => '0');
	signal data_i_2,data_i_3 : std_logic_vector(INT_SIG_WIDTH - 1 downto 0);
	signal data_q_2,data_q_3 : std_logic_vector(INT_SIG_WIDTH - 1 downto 0);


	signal en_i_1 : std_logic := '0';
begin
	data_i_2  <= std_logic_vector(signed(data_i_1) - signed(data_i_4));
	data_q_2  <= std_logic_vector(signed(data_q_1) - signed(data_q_4));

	--we add 1/2 LSB to perform rounding instead of truncation - lower quantization noise
	data_i_3  <= std_logic_vector(shift_right(signed(data_i_2) + to_signed(2**(COEFF_WIDTH-1),data_i_2'length) , COEFF_WIDTH) + signed(data_i_4));
	data_q_3  <= std_logic_vector(shift_right(signed(data_q_2) + to_signed(2**(COEFF_WIDTH-1),data_q_2'length) , COEFF_WIDTH) + signed(data_q_4));

	data_i_o  <= std_logic_vector(resize(shift_right(signed(data_i_4)+ to_signed(2**(COEFF_WIDTH-1),data_i_2'length) , COEFF_WIDTH),data_i_o'length));
	data_q_o  <= std_logic_vector(resize(shift_right(signed(data_q_4)+ to_signed(2**(COEFF_WIDTH-1),data_q_2'length) , COEFF_WIDTH),data_q_o'length));

	data_en_o <= en_i_1;
	data_clk_o <= data_clk_i;
	data_rst_o <= data_rst_i;

	process(data_clk_i) is 
	begin 
	if rising_edge(data_clk_i) then
		en_i_1 <= data_en_i;
		if (data_rst_i = '1') then 
			en_i_1 <= '0';
			data_i_1 <= (others => '0');
			data_q_1 <= (others => '0');
			data_i_4 <= (others => '0');
			data_q_4 <= (others => '0');

		end if;

		if (data_en_i = '1') then
			data_i_1 <= std_logic_vector(shift_left(resize(signed(data_i_i),INT_SIG_WIDTH),COEFF_WIDTH)); -- sample input data
			data_q_1 <= std_logic_vector(shift_left(resize(signed(data_q_i),INT_SIG_WIDTH),COEFF_WIDTH)); -- sample input data
		else 
			data_i_1 <= data_i_1;
			data_q_1 <= data_q_1;
		end if;
		if (en_i_1 = '1') then
			data_i_4 <= data_i_3; -- shift register
			data_q_4 <= data_q_3;
		else	
			data_i_4 <= data_i_4;
			data_q_4 <= data_q_4;

		end if;
	end if;
	end process;
end architecture bhv;
