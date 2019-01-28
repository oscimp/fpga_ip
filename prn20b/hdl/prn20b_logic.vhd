---------------------------------------------------------------------------
-- (c) Copyright: OscillatorIMP Digital
-- Author : Gwenhael Goavec-Merou<gwenhael.goavec-merou@trabucayre.com>
-- Creation date : 2018/06/11
---------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

entity prn20b_logic is
 	port (
		clk : in std_logic;
		reset : in std_logic;
		tick_i : in std_logic;
		-- start
		prn_o : out std_logic_vector(19 downto 0);
		bit_o : out std_logic
	);
end entity;
 
architecture rtl of prn20b_logic is
	signal lfsr_s, lfsr_next_s : std_logic_vector(19 downto 0) := (others => '1');
	signal xor20_17 	: std_logic;
	signal xorPlusOne	: std_logic;
begin

	prn_o <= lfsr_s;

	-- x^20+x^17+1
	xor20_17 <= lfsr_s(0) xor lfsr_s(3);
	xorPlusOne <= xor20_17 and '1';
	lfsr_next_s <= xorPlusOne & lfsr_s(19 downto 1);

	process(clk)
	begin
		if rising_edge(clk) then
			if (tick_i = '1') then
				lfsr_s <= lfsr_next_s;
			else
				lfsr_s <= lfsr_s;
			end if;
		end if;
	end process;
	bit_o <= lfsr_s(0);

end architecture rtl;
