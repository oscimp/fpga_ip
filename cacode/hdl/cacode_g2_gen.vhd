library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

entity cacode_g2_gen is
 	port (
		clk : in std_logic;
		reset : in std_logic;
		tick_i : in std_logic;
		-- start
		prn_o : out std_logic_vector(9 downto 0);
		bit_o : out std_logic
	);
end entity;
 
architecture rtl of cacode_g2_gen is
	signal lfsr_s, lfsr_next_s : std_logic_vector(9 downto 0) := (others => '1');
	signal xor_full 	: std_logic;
begin

	prn_o <= lfsr_s;

	xor_full <= lfsr_s(9) xor lfsr_s(8) xor lfsr_s(7)
		xor lfsr_s(5) xor lfsr_s(2) xor lfsr_s(1);
	lfsr_next_s <= lfsr_s(8 downto 0) & xor_full;

	process(clk)
	begin
		if rising_edge(clk) then
			if reset = '1' then
				lfsr_s <= (others => '1');
			elsif (tick_i = '1') then
				lfsr_s <= lfsr_next_s;
			else
				lfsr_s <= lfsr_s;
			end if;
		end if;
	end process;
	bit_o <= lfsr_s(9);

end architecture rtl;
