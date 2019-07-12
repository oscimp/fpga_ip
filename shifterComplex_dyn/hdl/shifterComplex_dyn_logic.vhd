---------------------------------------------------------------------------
-- (c) Copyright: OscillatorIMP Digital
-- Author : Gwenhael Goavec-Merou<gwenhael.goavec-merou@trabucayre.com>
-- Creation date : 2016/05/25
---------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

Entity shifterComplex_dyn_logic is 
	generic (
		SIGNED_FORMAT : boolean := true;
		MAX_SHIFT     : natural := 10;
		ADDR_SZ       : natural := 4;
		DATA_IN_SIZE  : natural := 32;
		DATA_OUT_SIZE : natural := 16
	);
	port 
	(
		rst_i       : in std_logic;
		clk_i       : in std_logic;
		shift_val_i : in std_logic_vector(ADDR_SZ-1 downto 0);
		-- input data
		data_i_i    : in std_logic_vector(DATA_IN_SIZE-1 downto 0);
		data_q_i    : in std_logic_vector(DATA_IN_SIZE-1 downto 0);
		data_en_i   : in std_logic;
		data_eof_i  : in std_logic;
		data_sof_i  : in std_logic;
		-- for the next component
		data_q_o    : out std_logic_vector(DATA_OUT_SIZE-1 downto 0);
		data_i_o    : out std_logic_vector(DATA_OUT_SIZE-1 downto 0);		
		data_en_o   : out std_logic;
		data_eof_o  : out std_logic;
		data_sof_o  : out std_logic
	);
end entity;
Architecture bhv of shifterComplex_dyn_logic is
	signal data_i_s, data_q_s       : std_logic_vector(DATA_OUT_SIZE-1 downto 0) := (others => '0');
	signal data_in_i_s, data_in_q_s : std_logic_vector(DATA_OUT_SIZE-1 downto 0) := (others => '0');
	signal data_en_s                : std_logic;
	signal data_eof_s               : std_logic;
	signal data_sof_s               : std_logic;

	type mux_array is array(natural range 0 to MAX_SHIFT) of
				std_logic_vector(DATA_OUT_SIZE-1 downto 0);
	type rest_array is array(natural range 0 to MAX_SHIFT) of boolean;
	signal array_val_i : mux_array;
	signal array_val_q : mux_array;

	signal rest_q_is_zero_s              : boolean;
	signal rest_q_is_zero_next_s         : boolean;
	signal rest_i_is_zero_s              : boolean;
	signal rest_i_is_zero_next_s         : boolean;
	signal array_rest_q_is_zero_s        : rest_array;
	signal array_rest_i_is_zero_s        : rest_array;
	signal neg_val_i_s, neg_val_i_next_s : boolean;
	signal neg_val_q_s, neg_val_q_next_s : boolean;
begin

	array_val_i(0) <= data_i_i(DATA_OUT_SIZE-1 downto 0);
	array_rest_i_is_zero_s(0) <= true;
	array_val_q(0) <= data_q_i(DATA_OUT_SIZE-1 downto 0);
	array_rest_q_is_zero_s(0) <= true;
	t: for i in 1 to MAX_SHIFT-1 generate
		array_val_i(i) <= data_i_i(DATA_OUT_SIZE+i-1 downto i);
		array_rest_i_is_zero_s(i) <= data_i_i(i-1 downto 0) = (i-1 downto 0 => '0');
		array_val_q(i) <= data_q_i(DATA_OUT_SIZE+i-1 downto i);
		array_rest_q_is_zero_s(i) <= data_q_i(i-1 downto 0) = (i-1 downto 0 => '0');
	end generate t;

	data_in_i_s <= array_val_i(to_integer(unsigned(shift_val_i)));
	rest_i_is_zero_next_s <= array_rest_i_is_zero_s(to_integer(unsigned(shift_val_i)));
	data_in_q_s <= array_val_q(to_integer(unsigned(shift_val_i)));
	rest_q_is_zero_next_s <= array_rest_q_is_zero_s(to_integer(unsigned(shift_val_i)));
	neg_val_i_next_s <= data_i_i(DATA_IN_SIZE-1) = '1';
	neg_val_q_next_s <= data_q_i(DATA_IN_SIZE-1) = '1';

	-- store data before shift
	process(clk_i)
	begin
		if rising_edge(clk_i) then
			if rst_i = '1' then
				data_i_s <= (others => '0');
				data_q_s <= (others => '0');
				data_en_s <= '0';
				data_eof_s <= '0';
				data_sof_s <= '0';
				rest_i_is_zero_s <= false;
				rest_q_is_zero_s <= false;
				neg_val_i_s <= false;
				neg_val_q_s <= false;
			elsif data_en_i = '1' then
				data_i_s <= data_in_i_s;
				data_q_s <= data_in_q_s;
				data_en_s <= '1';
				data_eof_s <= data_eof_i;
				data_sof_s <= data_sof_i;
				rest_i_is_zero_s <= rest_i_is_zero_next_s;
				rest_q_is_zero_s <= rest_q_is_zero_next_s;
				neg_val_i_s <= neg_val_i_next_s;
				neg_val_q_s <= neg_val_q_next_s;
			else
				data_i_s <= data_i_s;
				data_q_s <= data_q_s;
				data_en_s <= '0';
				data_eof_s <= '0';
				data_sof_s <= '0';
				rest_i_is_zero_s <= rest_i_is_zero_s;
				rest_q_is_zero_s <= rest_q_is_zero_s;
				neg_val_i_s <= neg_val_i_s;
				neg_val_q_s <= neg_val_q_s;
			end if;
		end if;
	end process;

	sig_gen: if SIGNED_FORMAT = true generate
		data_i_o <= std_logic_vector(signed(data_i_s) + 1) when not rest_i_is_zero_s and neg_val_i_s
			else data_i_s;
		data_q_o <= std_logic_vector(signed(data_q_s) + 1) when not rest_q_is_zero_s and neg_val_q_s
			else data_q_s;
	end generate sig_gen;

	unsig_gen: if SIGNED_FORMAT /= true generate
		data_i_o <= data_i_s;
		data_q_o <= data_q_s;
	end generate unsig_gen;

	data_en_o <= data_en_s;
	data_eof_o <= data_eof_s;
	data_sof_o <= data_sof_s;

end architecture bhv;
