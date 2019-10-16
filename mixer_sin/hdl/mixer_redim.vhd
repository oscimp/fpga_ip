---------------------------------------------------------------------------
-- (c) Copyright: OscillatorIMP Digital
-- Author : Gwenhael Goavec-Merou<gwenhael.goavec-merou@trabucayre.com>
-- Creation date : 2016/09/14
---------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

entity mixer_redim is
	generic (
		SIGNED_FORMAT: boolean := false;
		IN_SZ        : natural := 16;
		OUT_SZ       : natural := 16
	);
	port (
		-- candr
		clk_i     : in std_logic;
		rst_i     : in std_logic;
		-- in interface
		data_en_i : in std_logic;
		data_i_i  : in std_logic_vector(IN_SZ-1 downto 0);
		data_q_i  : in std_logic_vector(IN_SZ-1 downto 0);
		-- out interface
		data_en_o : out std_logic;
		data_i_o  : out std_logic_vector(OUT_SZ-1 downto 0);
		data_q_o  : out std_logic_vector(OUT_SZ-1 downto 0)
	);
end mixer_redim;

architecture Behavioral of mixer_redim is
    function sub_min_to_max(size1, size2: natural) return natural is begin
	if (size1 > size2) then return size1 - size2;
	else                    return size2 - size1;
	end if;
	end function sub_min_to_max;
	constant SHFT_SZ : natural := sub_min_to_max(IN_SZ, OUT_SZ);
	signal data_en_in_s : std_logic;
	signal data_i_in_s, data_q_in_s : std_logic_vector(OUT_SZ-1 downto 0);
	signal i_d1_s, q_d1_s : std_logic_vector(OUT_SZ-1 downto 0);
	signal data_en_out_s : std_logic;
	signal data_i_out_s, data_q_out_s : std_logic_vector(OUT_SZ-1 downto 0);
																	 
	signal i_is_neg_s, q_is_neg_s         : signed(1 downto 0);
	signal i_is_neg_d0_s, q_is_neg_d0_s   : signed(1 downto 0);
	signal i_is_null_s, q_is_null_s       : boolean;
	signal i_is_null_d0_s, q_is_null_d0_s : boolean;
	constant ALL_ZERO: std_logic_vector(SHFT_SZ-1 downto 0) := (SHFT_SZ-1 downto 0 => '0');
	constant ALL_ONE : std_logic_vector(SHFT_SZ-1 downto 0) := (SHFT_SZ-1 downto 0 => '1');

	signal shft_dat_i_s : std_logic_vector(IN_SZ-1 downto 0);
	signal shft_dat_q_s : std_logic_vector(IN_SZ-1 downto 0);
begin
	-- determine if value is < 0 (MSB = 1)
	-- for unsigned values these signals must be
	-- always false since MSB is not a sign bit
	unsig_fmt: if (SIGNED_FORMAT = false) generate
		i_is_neg_d0_s <= "00";
		q_is_neg_d0_s <= "00";
	end generate unsig_fmt;
	sig_fmt: if (SIGNED_FORMAT = true) generate
		i_is_neg_d0_s <= '0'&data_i_i(IN_SZ-1);
		q_is_neg_d0_s <= '0'&data_q_i(IN_SZ-1);
	end generate sig_fmt;

	-- no shift right => in data stay at the same position in out data
	expand_or_none: if (OUT_SZ >= IN_SZ) generate
		data_en_in_s <= data_en_i;
		-- in all case in is not moved in out
		data_i_in_s(IN_SZ-1 downto 0) <= data_i_i(IN_SZ-1 downto 0);
		data_q_in_s(IN_SZ-1 downto 0) <= data_q_i(IN_SZ-1 downto 0);

		i_is_neg_s <= i_is_neg_d0_s;
		q_is_neg_s <= q_is_neg_d0_s;

		-- extend with MSB bit when signed
		-- and always with 0 if unsigned (since x_is_neg_s is always false)
		expand: if (OUT_SZ > IN_SZ) generate
			data_i_in_s(OUT_SZ-1 downto IN_SZ) <= ALL_ONE when i_is_neg_s(0) = '1'
					else ALL_ZERO;
			data_q_in_s(OUT_SZ-1 downto IN_SZ) <= ALL_ONE when q_is_neg_s(0) = '1'
					else ALL_ZERO;
		end generate expand;

		i_d1_s <= data_i_in_s;
		q_d1_s <= data_q_in_s;
	end generate expand_or_none;

	-- when out < in => shift in to match out size
	shift_data: if (OUT_SZ < IN_SZ) generate
		-- used to determine if rest is 0 or something else
		i_is_null_d0_s <= data_i_i(SHFT_SZ-1 downto 0) = ALL_ZERO;
		q_is_null_d0_s <= data_q_i(SHFT_SZ-1 downto 0) = ALL_ZERO;

		shft_dat_i_s <= std_logic_vector(shift_right(unsigned(data_i_i), SHFT_SZ));
		shft_dat_q_s <= std_logic_vector(shift_right(unsigned(data_q_i), SHFT_SZ));
		process(clk_i) begin
			if rising_edge(clk_i) then
				if (rst_i = '1') then
					i_is_neg_s(0) <= '0';
					q_is_neg_s(0) <= '0';

					i_is_null_s <= false;
					q_is_null_s <= false;

					data_en_in_s <= '0';
					data_i_in_s <= (others => '0');
					data_q_in_s <= (others => '0');
				else
					i_is_neg_s <= i_is_neg_d0_s;
					q_is_neg_s <= q_is_neg_d0_s;

					i_is_null_s <= i_is_null_d0_s;
					q_is_null_s <= q_is_null_d0_s;

					data_en_in_s <= data_en_i;
					data_i_in_s <= shft_dat_i_s(OUT_SZ-1 downto 0);
					data_q_in_s <= shft_dat_q_s(OUT_SZ-1 downto 0);
				end if;
			end if;
		end process;
		i_d1_s <= std_logic_vector(signed(data_i_in_s) + i_is_neg_s) when not i_is_null_s
				else data_i_in_s;
		q_d1_s <= std_logic_vector(signed(data_q_in_s) + q_is_neg_s) when not q_is_null_s
				else data_q_in_s;
	end generate shift_data;

	process(clk_i) begin
		if rising_edge(clk_i) then
			if (rst_i = '1') then
				data_en_out_s <= '0';
				data_i_out_s  <= (others => '0');
				data_q_out_s  <= (others => '0');
			elsif data_en_in_s = '1' then
				data_en_out_s <= '1';
				data_i_out_s  <= i_d1_s;
				data_q_out_s  <= q_d1_s;
			else
				data_en_out_s <= '0';
				data_i_out_s  <= data_i_out_s;
				data_q_out_s  <= data_q_out_s;
			end if;
		end if;
	end process;

	data_en_o <= data_en_out_s;
	data_i_o <= std_logic_vector(data_i_out_s);
	data_q_o <= std_logic_vector(data_q_out_s);

end Behavioral;
