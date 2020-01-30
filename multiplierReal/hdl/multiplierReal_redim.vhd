---------------------------------------------------------------------------
-- (c) Copyright: OscillatorIMP Digital
-- Author : Gwenhael Goavec-Merou<gwenhael.goavec-merou@trabucayre.com>
-- Creation date : 2016/09/14
---------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

entity multiplierReal_redim is
	generic (
		SIGNED_FORMAT: boolean := false;
		IN_SZ        : natural := 16;
		OUT_SZ       : natural := 16
	);
	port (
		-- candr
		clk_i      : in std_logic;
		rst_i      : in std_logic;
		-- in interface
		data_i     : in std_logic_vector(IN_SZ-1 downto 0);
		data_en_i  : in std_logic;
		data_eof_i : in std_logic;
		data_sof_i : in std_logic;
		-- out interface
		data_en_o  : out std_logic;
		data_eof_o : out std_logic;
		data_sof_o : out std_logic;
		data_o     : out std_logic_vector(OUT_SZ-1 downto 0)
	);
end multiplierReal_redim;

architecture Behavioral of multiplierReal_redim is
    function sub_min_to_max(size1, size2: natural) return natural is begin
	if (size1 > size2) then return size1 - size2;
	else                    return size2 - size1;
	end if;
	end function sub_min_to_max;
	constant SHFT_SZ : natural := sub_min_to_max(IN_SZ, OUT_SZ);
	signal data_en_in_s, data_eof_in_s, data_sof_in_s : std_logic;
	signal data_in_s : std_logic_vector(OUT_SZ-1 downto 0);
	signal d1_s : std_logic_vector(OUT_SZ-1 downto 0);
	signal data_en_out_s, data_eof_out_s, data_sof_out_s : std_logic;
	signal data_out_s : std_logic_vector(OUT_SZ-1 downto 0);
																	 
	signal is_neg_s     : signed(1 downto 0);
	signal is_neg_d0_s  : signed(1 downto 0);
	signal is_null_s    : boolean;
	signal is_null_d0_s : boolean;
	constant ALL_ZERO: std_logic_vector(SHFT_SZ-1 downto 0) := (SHFT_SZ-1 downto 0 => '0');
	constant ALL_ONE : std_logic_vector(SHFT_SZ-1 downto 0) := (SHFT_SZ-1 downto 0 => '1');

	signal shft_dat_s   : std_logic_vector(IN_SZ-1 downto 0);
	signal shft_dat_q_s : std_logic_vector(IN_SZ-1 downto 0);
begin
	-- determine if value is < 0 (MSB = 1)
	-- for unsigned values these signals must be
	-- always false since MSB is not a sign bit
	unsig_fmt: if (SIGNED_FORMAT = false) generate
		is_neg_d0_s <= "00";
	end generate unsig_fmt;
	sig_fmt: if (SIGNED_FORMAT = true) generate
		is_neg_d0_s <= '0'&data_i(IN_SZ-1);
	end generate sig_fmt;

	-- no shift right => in data stay at the same position in out data
	expand_or_none: if (OUT_SZ >= IN_SZ) generate
		data_en_in_s <= data_en_i;
		data_eof_in_s <= data_eof_i;
		data_sof_in_s <= data_sof_i;
		-- in all case in is not moved in out
		data_in_s(IN_SZ-1 downto 0) <= data_i(IN_SZ-1 downto 0);

		is_neg_s <= is_neg_d0_s;

		-- extend with MSB bit when signed
		-- and always with 0 if unsigned (since x_is_neg_s is always false)
		expand: if (OUT_SZ > IN_SZ) generate
			data_in_s(OUT_SZ-1 downto IN_SZ) <= ALL_ONE when is_neg_s(0) = '1'
					else ALL_ZERO;
		end generate expand;

		d1_s <= data_in_s;
	end generate expand_or_none;

	-- when out < in => shift in to match out size
	shift_data: if (OUT_SZ < IN_SZ) generate
		-- used to determine if rest is 0 or something else
		is_null_d0_s <= data_i(SHFT_SZ-1 downto 0) = ALL_ZERO;

		shft_dat_s <= std_logic_vector(shift_right(unsigned(data_i), SHFT_SZ));
		process(clk_i) begin
			if rising_edge(clk_i) then
				if (rst_i = '1') then
					is_neg_s(0) <= '0';

					is_null_s <= false;

					data_en_in_s <= '0';
					data_in_s <= (others => '0');
				else
					is_neg_s <= is_neg_d0_s;

					is_null_s <= is_null_d0_s;

					data_en_in_s <= data_en_i;
					data_eof_in_s <= data_eof_i;
					data_sof_in_s <= data_sof_i;
					data_in_s <= shft_dat_s(OUT_SZ-1 downto 0);
				end if;
			end if;
		end process;
		d1_s <= std_logic_vector(signed(data_in_s) + is_neg_s) when not is_null_s
				else data_in_s;
	end generate shift_data;

	process(clk_i) begin
		if rising_edge(clk_i) then
			if (rst_i = '1') then
				data_en_out_s  <= '0';
				data_eof_out_s <= '0';
				data_sof_out_s <= '0';
				data_out_s    <= (others => '0');
			elsif data_en_in_s = '1' then
				data_en_out_s  <= '1';
				data_eof_out_s <= '1';
				data_sof_out_s <= '1';
				data_out_s     <= d1_s;
			else
				data_en_out_s  <= '0';
				data_eof_out_s <= '0';
				data_sof_out_s <= '0';
				data_out_s     <= data_out_s;
			end if;
		end if;
	end process;

	data_en_o <= data_en_out_s;
	data_eof_o <= data_eof_out_s;
	data_sof_o <= data_sof_out_s;
	data_o <= std_logic_vector(data_out_s);

end Behavioral;
