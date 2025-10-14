---------------------------------------------------------------------------
-- (c) Copyright: Femto Engineering
-- Author: Benoit Dubois <benoit.dubois@femto-engineering.fr>
-- Creation date: 2024/04/15
---------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
use IEEE.math_real.all;

library work;
use work.common.all;

Entity cicComplex_top is
	generic (
		BIT_PRUNING : boolean := true;
		data_signed : boolean := true;
		DECIMATE_FACTOR : natural := 8;
		DIFFERENTIAL_DELAY : natural := 1;
		ORDER : natural := 2;
		DATA_IN_SIZE : natural := 16;
		DATA_OUT_SIZE : natural := 23
	);
	port (
		-- Syscon signals
		reset : in std_ulogic;
		clk   : in std_ulogic;
		-- input data
		data_en_i : in std_ulogic;
		data_i_i  : in std_logic_vector(DATA_IN_SIZE-1 downto 0);
		data_q_i  : in std_logic_vector(DATA_IN_SIZE-1 downto 0);
		-- for the next component
		data_i_o  : out std_logic_vector(DATA_OUT_SIZE-1 downto 0);
		data_q_o  : out std_logic_vector(DATA_OUT_SIZE-1 downto 0);
		data_en_o : out std_ulogic
	);
end entity cicComplex_top;

---------------------------------------------------------------------------
Architecture rtl of cicComplex_top is
---------------------------------------------------------------------------
	--
	constant DATA_INT_SIZE : natural := GetIntInputSize(DATA_IN_SIZE, data_signed);
	constant DATA_OUTT_SIZE : natural := GetIntInputSize(DATA_OUT_SIZE, data_signed);
	-- Internal register size (Computed to avoid overflow)
	constant REGISTER_MAX : integer := Bmax(DATA_INT_SIZE, DECIMATE_FACTOR, ORDER, DIFFERENTIAL_DELAY);
	constant REGISTER_SIZE : coeff_t := CicRegSize(BIT_PRUNING, DATA_IN_SIZE, DATA_OUT_SIZE, DECIMATE_FACTOR, ORDER, DIFFERENTIAL_DELAY);
	-- Try and make sure the CIC gain is designed to be a power of 2.
	constant SHIFT_GAIN : natural := 0;  --Gain(DECIMATE_FACTOR, ORDER, DIFFERENTIAL_DELAY);
	--
	subtype reg_t is signed(REGISTER_MAX-1 downto 0);
	type reg_array_t is array (1 to ORDER-1) of reg_t;
	--
	signal data_i_d0_s : signed(DATA_INT_SIZE-1 downto 0) := (others => '0');
	signal data_q_d0_s : signed(DATA_INT_SIZE-1 downto 0) := (others => '0');
	signal data_i_se_s : reg_t := (others => '0');
	signal data_q_se_s : reg_t := (others => '0');
	--
	signal int_data_i_s : reg_array_t := (others => (others => '0'));
	signal int_data_q_s : reg_array_t := (others => (others => '0'));
	signal int_out_i_s : reg_t := (others => '0');
	signal int_out_q_s : reg_t := (others => '0');
	-- Decimator state.
	signal count_s : integer range 0 to (DECIMATE_FACTOR-1) := 0;
	signal data_en_s : std_logic := '1';
	signal comb_data_i_s : reg_array_t := (others => (others => '0'));
	signal comb_data_q_s : reg_array_t := (others => (others => '0'));
	signal comb_out_i_s : reg_t := (others => '0');
	signal comb_out_q_s : reg_t := (others => '0');
begin

	is_unsigned_format: if data_signed /= true generate
		data_i_d0_s <= '0' & signed(data_i_i);
		data_q_d0_s <= '0' & signed(data_q_i);
	end generate is_unsigned_format;
	is_signed_format: if data_signed = true generate
		data_i_d0_s <= signed(data_i_i);
		data_q_d0_s <= signed(data_q_i);
	end generate is_signed_format;

	-- -------------------------------------------------------------------------
	--	Sign extension.
	-- -------------------------------------------------------------------------
	SE : process(data_i_d0_s, data_q_d0_s)
	begin
		data_i_se_s(DATA_INT_SIZE-1 downto 0) <= data_i_d0_s;
		data_q_se_s(DATA_INT_SIZE-1 downto 0) <= data_q_d0_s;
		for k in (REGISTER_MAX-1) downto DATA_INT_SIZE loop
			data_i_se_s(k) <= data_i_d0_s(data_i_d0_s'high);
			data_q_se_s(k) <= data_q_d0_s(data_q_d0_s'high);
		end loop;
	end process SE;

	-- -------------------------------------------------------------------------
	--	Integrator
	-- -------------------------------------------------------------------------
	GEN_INTEGRATOR_1: if ORDER = 1 generate
		INT_11: entity work.integrator
		generic map(
			DATA_SIZE => REGISTER_SIZE(0))
		port map (
			clk => clk,
			reset => reset,
			data_en_i => data_en_i,
			data_i_i => data_i_se_s,
			data_q_i => data_q_se_s,
			data_i_o => int_out_i_s,
			data_q_o => int_out_q_s
		);
	end generate GEN_INTEGRATOR_1;

	GEN_INTEGRATOR_2: if ORDER = 2 generate
	begin
		INT_21: entity work.integrator
		generic map(
			DATA_SIZE => REGISTER_SIZE(0))
		port map (
			clk => clk,
			reset => reset,
			data_en_i => data_en_i,
			data_i_i => data_i_se_s,
			data_q_i => data_q_se_s,
			data_i_o => int_data_i_s(1),
			data_q_o => int_data_q_s(1)
		);
		INT_22: entity work.integrator
		generic map(
			DATA_SIZE => REGISTER_SIZE(1))
		port map (
			clk => clk,
			reset => reset,
			data_en_i => data_en_i,
			data_i_i => int_data_i_s(1),
			data_q_i => int_data_q_s(1),
			data_i_o => int_out_i_s,
			data_q_o => int_out_q_s
		);
	end generate GEN_INTEGRATOR_2;

	GEN_INTEGRATOR_N: if ORDER > 2 generate
	begin
		INTEGRATOR_N: for i in 1 to ORDER generate
		begin
			-- Generate the first integrator filter.
			GEN_INT_1 : if i = 1 generate
			begin
				INT_N1 : entity work.integrator
				generic map(
					DATA_SIZE => REGISTER_SIZE(0))
				port map (
					clk => clk,
					reset => reset,
					data_en_i => data_en_i,
					data_i_i => data_i_se_s(data_i_se_s'high downto data_i_se_s'high-REGISTER_SIZE(0)+1),
					data_q_i => data_q_se_s(data_i_se_s'high downto data_i_se_s'high-REGISTER_SIZE(0)+1),
					data_i_o => int_data_i_s(1)(int_data_i_s(1)'high downto int_data_i_s(1)'high-REGISTER_SIZE(0)+1),
					data_q_o => int_data_q_s(1)(int_data_q_s(1)'high downto int_data_q_s(1)'high-REGISTER_SIZE(0)+1)
				);
			end generate GEN_INT_1;
			-- Generate the i'th integrator filter.
			GEN_INT_I : if ((i > 1) and (i < ORDER)) generate
			begin
				INT_NI : entity work.integrator
				generic map(
					DATA_SIZE => REGISTER_SIZE(i-1))
				port map (
					clk => clk,
					reset => reset,
					data_en_i => data_en_i,
					data_i_i => int_data_i_s(i-1)(int_data_i_s(i-1)'high downto int_data_i_s(i-1)'high-REGISTER_SIZE(i-1)+1),
					data_q_i => int_data_q_s(i-1)(int_data_q_s(i-1)'high downto int_data_q_s(i-1)'high-REGISTER_SIZE(i-1)+1),
					data_i_o => int_data_i_s(i)(int_data_i_s(i)'high downto int_data_i_s(i)'high-REGISTER_SIZE(i-1)+1),
					data_q_o => int_data_q_s(i)(int_data_q_s(i)'high downto int_data_q_s(i)'high-REGISTER_SIZE(i-1)+1)
				);
			end generate GEN_INT_I;
			-- Generate the ORDER'th integrator filter.
			GEN_INT_ORDER : if i = ORDER generate
			begin
				INT_NORDER : entity work.integrator
				generic map(
					DATA_SIZE => REGISTER_SIZE(ORDER))
				port map (
					clk => clk,
					reset => reset,
					data_en_i => data_en_i,
					data_i_i => int_data_i_s(ORDER-1)(int_data_i_s(ORDER-1)'high downto int_data_i_s(ORDER-1)'high-REGISTER_SIZE(ORDER)+1),
					data_q_i => int_data_q_s(ORDER-1)(int_data_q_s(ORDER-1)'high downto int_data_q_s(ORDER-1)'high-REGISTER_SIZE(ORDER)+1),
					data_i_o => int_out_i_s(int_out_i_s'high downto int_out_i_s'high-REGISTER_SIZE(ORDER)+1),
					data_q_o => int_out_q_s(int_out_q_s'high downto int_out_q_s'high-REGISTER_SIZE(ORDER)+1)
				);
			end generate GEN_INT_ORDER;
		end generate INTEGRATOR_N;
	end generate GEN_INTEGRATOR_N;

	-- -------------------------------------------------------------------------
	--	Decimator
	-- -------------------------------------------------------------------------
	GEN_DECIMATOR : process(clk, reset)
	begin
		if reset = '1' then
			count_s <= 0;
		elsif rising_edge(clk) then
			if (data_en_i = '1') then
				if count_s >= (DECIMATE_FACTOR-1) then
					count_s <= 0;
				else
					count_s <= count_s + 1;
				end if;
			end if;
		end if;
	end process GEN_DECIMATOR;

	data_en_s <= '1' when count_s = 0 else '0';


	-- -------------------------------------------------------------------------
	--	Comb
	-- -------------------------------------------------------------------------
	GEN_COMB_1: if ORDER = 1 generate
		INT_11: entity work.comb
		generic map(
			DATA_SIZE => REGISTER_SIZE(ORDER+1),
			DIFFERENTIAL_DELAY => DIFFERENTIAL_DELAY)
		port map (
			clk => clk,
			reset => reset,
			data_i_i => int_out_i_s,
			data_q_i => int_out_q_s,
			data_i_o => comb_out_i_s,
			data_q_o => comb_out_q_s,
			data_en_i => data_en_s
		);
	end generate GEN_COMB_1;

	GEN_COMB_2: if ORDER = 2 generate
	begin
		INT_21: entity work.comb
		generic map(
			DATA_SIZE => REGISTER_SIZE(ORDER+1),
			DIFFERENTIAL_DELAY => DIFFERENTIAL_DELAY)
		port map (
			clk => clk,
			reset => reset,
			data_i_i => int_out_i_s,
			data_q_i => int_out_q_s,
			data_i_o => comb_data_i_s(1),
			data_q_o => comb_data_q_s(1),
			data_en_i => data_en_s
		);
		INT_22: entity work.comb
		generic map(
			DATA_SIZE => REGISTER_SIZE(ORDER+2),
			DIFFERENTIAL_DELAY => DIFFERENTIAL_DELAY)
		port map (
			clk => clk,
			reset => reset,
			data_i_i => comb_data_i_s(1),
			data_q_i => comb_data_q_s(1),
			data_i_o => comb_out_i_s,
			data_q_o => comb_out_q_s,
			data_en_i => data_en_s
		);
	end generate GEN_COMB_2;

	GEN_COMB_N : if ORDER > 2 generate
	begin
		COMB_N: for i in 1 to ORDER generate
		begin
			-- Generate the first comb filter.
			GEN_COMB_N1: if i = 1 generate
			begin
				CMB_1 : entity work.comb
				generic map(
					DATA_SIZE => REGISTER_SIZE(ORDER+1),
					DIFFERENTIAL_DELAY => DIFFERENTIAL_DELAY)
				port map (
					clk => clk,
					reset => reset,
					data_i_i => int_out_i_s(int_out_i_s'high downto int_out_i_s'high-REGISTER_SIZE(ORDER+1)+1),
					data_q_i => int_out_q_s(int_out_q_s'high downto int_out_q_s'high-REGISTER_SIZE(ORDER+1)+1),
					data_i_o => comb_data_i_s(1)(comb_data_i_s(1)'high downto comb_data_i_s(1)'high-REGISTER_SIZE(ORDER+1)+1),
					data_q_o => comb_data_q_s(1)(comb_data_i_s(1)'high downto comb_data_i_s(1)'high-REGISTER_SIZE(ORDER+1)+1),
					data_en_i => data_en_s
				);
			end generate GEN_COMB_N1;
			-- Generate the i'th comb filter.
			GEN_COMB_NI : if ((i > 1) and (i < ORDER)) generate
			begin
				CMB_1 : entity work.comb
				generic map(
					DATA_SIZE => REGISTER_SIZE(ORDER+i+1),
					DIFFERENTIAL_DELAY => DIFFERENTIAL_DELAY)
				port map (
					clk => clk,
					reset => reset,
					data_i_i => comb_data_i_s(i-1)(comb_data_i_s(i-1)'high downto comb_data_i_s(i-1)'high-REGISTER_SIZE(ORDER+i+1)+1),
					data_q_i => comb_data_q_s(i-1)(comb_data_q_s(i-1)'high downto comb_data_q_s(i-1)'high-REGISTER_SIZE(ORDER+i+1)+1),
					data_i_o => comb_data_i_s(i)(comb_data_i_s(i)'high downto comb_data_i_s(i)'high-REGISTER_SIZE(ORDER+i+1)+1),
					data_q_o => comb_data_q_s(i)(comb_data_q_s(i)'high downto comb_data_q_s(i)'high-REGISTER_SIZE(ORDER+i+1)+1),
					data_en_i => data_en_s
				);
			end generate GEN_COMB_NI;
			-- Generate the ORDER'th comb filter.
			GEN_COMB_NORDER : if i = ORDER generate
			begin
				CMB_1 : entity work.comb
				generic map(
					DATA_SIZE => REGISTER_SIZE(2*ORDER),
					DIFFERENTIAL_DELAY => DIFFERENTIAL_DELAY)
				port map (
					clk => clk,
					reset => reset,
					data_i_i => comb_data_i_s(ORDER-1)(comb_data_i_s(2*ORDER)'high downto comb_data_i_s(2*ORDER)'high-REGISTER_SIZE(2*ORDER)+1),
					data_q_i => comb_data_q_s(ORDER-1)(comb_data_q_s(2*ORDER)'high downto comb_data_q_s(2*ORDER)'high-REGISTER_SIZE(2*ORDER)+1),
					data_i_o => comb_out_i_s(comb_out_i_s'high downto comb_out_i_s'high-REGISTER_SIZE(2*ORDER)+1),
					data_q_o => comb_out_q_s(comb_out_q_s'high downto comb_out_q_s'high-REGISTER_SIZE(2*ORDER)+1),
					data_en_i => data_en_s
				);
			end generate GEN_COMB_NORDER;
		end generate COMB_N;
	end generate GEN_COMB_N;

	-- Data output enable generation
	data_en_o <= data_en_s;

	-- -------------------------------------------------------------------------
	--	Remove DC Gain and final bit truncation.
	-- -------------------------------------------------------------------------
	data_i_o <= std_logic_vector(resize(shift_right(comb_out_i_s, SHIFT_GAIN), data_i_o'length));
	data_q_o <= std_logic_vector(resize(shift_right(comb_out_q_s, SHIFT_GAIN), data_q_o'length));

end architecture rtl;
