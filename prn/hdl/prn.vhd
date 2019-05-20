---------------------------------------------------------------------------
-- (c) Copyright: OscillatorIMP Digital
-- Author : Gwenhael Goavec-Merou<gwenhael.goavec-merou@trabucayre.com>
-- Creation date : 2019/05/18
---------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
use IEEE.math_real.all;

entity prn is
	generic (PERIOD_LEN : natural := 1
	);
 	port (
		clk    : in std_logic;
		reset  : in std_logic;
		tick_i : in std_logic;
		prn_o  : out std_logic
	);
end entity;
 
architecture rtl of prn is
	constant PERIOD_WIDTH      : natural := natural(ceil(log2(real(PERIOD_LEN))));
	signal period_s            : unsigned(PERIOD_WIDTH-1 downto 0);
	signal tick_int_s          : std_logic;
	signal lfsr_s, lfsr_next_s : std_logic_vector(6 downto 0) := (others => '1');
	signal xor0_6 	           : std_logic;
begin
	
	prescaler_gen : if (PERIOD_LEN > 1) generate
		process(clk) begin
			if rising_edge(clk) then
				if (reset or tick_int_s) = '1' then
					period_s <= to_unsigned(PERIOD_LEN-1, PERIOD_WIDTH);
				elsif (tick_i = '1') then
					period_s <= period_s - 1;
				else
					period_s <= period_s;
				end if;
			end if;
		end process;

	tick_int_s <= tick_i when (period_s = 0) else '0';
	end generate prescaler_gen;

	no_prescaler: if (PERIOD_LEN = 1) generate
		tick_int_s <= tick_i;
	end generate no_prescaler;


	-- x^7+x^1+1
	xor0_6      <= lfsr_s(0) xor lfsr_s(6);
	lfsr_next_s <= lfsr_s(5 downto 0) & xor0_6;

	process(clk) begin
		if rising_edge(clk) then
			if (tick_int_s = '1') then
				lfsr_s <= lfsr_next_s;
			else
				lfsr_s <= lfsr_s;
			end if;
		end if;
	end process;

	prn_o <= lfsr_s(0);

end architecture rtl;
