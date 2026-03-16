---------------------------------------------------------------------------
-- (c) Copyright: FemtoEngineering
-- Author : Benoit Dubois <benoit.dubois@femto-engineering.fr>
-- Creation date : 2024/04/15
---------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
use IEEE.math_real.all;

library work;
use work.common.all;

Entity cicReal_top is 
	generic (
		data_signed : boolean := true;
		DECIMATE_FACTOR : natural := 8;
		ORDER : natural := 3;
		N     : natural := 1;
		DATA_SIZE     : natural := 16;
		DATA_OUT_SIZE : natural := 23
	);
	port (
		-- Syscon signals
		reset   : in std_ulogic;
		clk		: in std_ulogic;
		-- input data
		data_en_i : in std_ulogic;
		data_i    : in std_logic_vector(DATA_SIZE-1 downto 0);
		-- for the next component
		data_o    : out std_logic_vector(DATA_OUT_SIZE-1 downto 0);		
		data_en_o : out std_ulogic
	);
end entity cicReal_top;

---------------------------------------------------------------------------
Architecture rtl of cicReal_top is
---------------------------------------------------------------------------
	function getIntInputSize(data_in_size : natural; is_signed: boolean) return natural is
    begin
		if (is_signed) then
			return data_in_size;
		end if;
        return data_in_size + 1;
    end function getIntInputSize;
	--
	constant DATA_INT_SIZE : natural := getIntInputSize(DATA_SIZE, data_signed);
	-- Internal register size (Compututed to avoid overflow)
	constant REGISTER_SIZE : integer := Bmax(DATA_INT_SIZE, DECIMATE_FACTOR, ORDER, N);
	-- Try and make sure the CIC gain is designed to be a power of 2.
	constant SHIFT_GAIN : natural := Gain(DECIMATE_FACTOR, ORDER, N);
	--
	subtype reg_t is signed(REGISTER_SIZE-1 downto 0);
	type reg_array_t is array (1 to ORDER) of reg_t;
	--
	signal data_d0_s : signed(DATA_INT_SIZE-1 downto 0);
	signal data_se_s : reg_t := (others => '0');
	--
	signal int_data_s : reg_array_t;
	signal int_out_s : reg_t := (others => '0');
	-- Decimator state.
	signal sample_s : std_logic := '0';
	signal comb_data_s : reg_array_t;
	signal comb_out_s : reg_t := (others => '0');
begin

	is_unsigned_format: if data_signed /= true generate
		data_d0_s <= '0' & signed(data_i);
	end generate is_unsigned_format;
	is_signed_format: if data_signed = true generate
		data_d0_s <= signed(data_i);
	end generate is_signed_format;

	-- -------------------------------------------------------------------------
	--	Sign extension.
	-- -------------------------------------------------------------------------
	SE : process(data_d0_s)
	begin
		data_se_s(DATA_INT_SIZE-1 downto 0) <= data_d0_s;
		for k in (REGISTER_SIZE-1) downto DATA_INT_SIZE loop
			data_se_s(k) <= data_d0_s(data_d0_s'high);
		end loop;
	end process SE;

	-- -------------------------------------------------------------------------	
	--	Integrator
	-- -------------------------------------------------------------------------
	GEN_INTEGRATOR: for i in 1 to ORDER generate
	begin
		-- Generate the first integrator filter.
		GEN_INT_1 : if i = 1 generate
		begin
			INT_1 : entity work.integrator 
			generic map(
				DATA_SIZE=>REGISTER_SIZE) 
			port map (
				clk => clk,
				data_i => data_se_s,
				data_o => int_data_s(1)
			);
		end generate GEN_INT_1;
		-- Generate the i'th integrator filter.
		GEN_INT_I : if ((i > 1) and (i < ORDER)) generate
		begin
			INT_1 : entity work.integrator 
			generic map(
				DATA_SIZE=>REGISTER_SIZE) 
			port map (
				clk => clk,
				data_i => int_data_s(i-1),
				data_o => int_data_s(i)
			);
		end generate GEN_INT_I;
		-- Generate the ORDER'th integrator filter.
		GEN_INT_ORDER : if i = ORDER generate
		begin
			INT_1 : entity work.integrator
			generic map(
				DATA_SIZE=>REGISTER_SIZE) 
			port map (
				clk => clk,
				data_i => int_data_s(ORDER-1),
				data_o => int_out_s
			);
		end generate GEN_INT_ORDER;
	end generate GEN_INTEGRATOR;

	-- -------------------------------------------------------------------------
	--	Decimator
	-- -------------------------------------------------------------------------
	GeN_DECIMATOR : process(clk, reset)
		variable count_v : integer range 0 to (DECIMATE_FACTOR-1) := 0;
	begin
		if reset = '0' then
			count_v := 0;
			sample_s <= '0';
		elsif rising_edge(clk) then
			if count_v >= (DECIMATE_FACTOR - 1) then
				count_v := 0;
				sample_s <= '1';
			else
				count_v := count_v + 1;
				sample_s <= '0';
			end if;
		end if;
	end process GEN_DECIMATOR;

	-- -------------------------------------------------------------------------
	--	Comb
	-- -------------------------------------------------------------------------
	GEN_COMB : for i in 1 to ORDER generate
	begin
		-- Generate the first comb filter.
		GEN_COMB_1 : if i = 1 generate
		begin
			CMB_1 : entity work.comb
			generic map(
				DATA_SIZE=>REGISTER_SIZE)
			port map (
				clk => clk,
				data_i => int_out_s,
				data_o => comb_data_s(i),
				sample_i => sample_s
			);
		end generate GEN_COMB_1;
		-- Generate the i'th comb filter.
		GEN_COMB_I : if ((i > 1) and (i < ORDER)) generate
		begin
			CMB_1 : entity work.comb
			generic map(
				DATA_SIZE=>REGISTER_SIZE)
			port map (
				clk => clk,
				data_i => comb_data_s(i - 1),
				data_o => comb_data_s(i),
				sample_i => sample_s
			);
		end generate GEN_COMB_I;
		-- Generate the ORDER'th comb filter.
		GEN_COMB_ORDER : if i = ORDER generate
		begin
			CMB_1 : entity work.comb
			generic map(
				DATA_SIZE=>REGISTER_SIZE)
			port map (
				clk => clk,
				data_i => comb_data_s(i - 1),
				data_o => comb_out_s,
				sample_i => sample_s
			);
		end generate GEN_COMB_ORDER;
	end generate GEN_COMB;

	-- Data output enable generation
	data_en_o <= sample_s;

	-- -------------------------------------------------------------------------
	--	Remove DC Gain and final bit truncation.
	-- -------------------------------------------------------------------------
	data_o <= std_logic_vector(resize(shift_right(comb_out_s, SHIFT_GAIN), data_o'length)); --(DATA_OUT_SIZE - 1 downto DATA_OUT_SIZE-DATA_OUT_SIZE);

end architecture rtl;
