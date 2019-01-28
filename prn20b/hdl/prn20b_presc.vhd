---------------------------------------------------------------------------
-- (c) Copyright: OscillatorIMP Digital
-- Author : Gwenhael Goavec-Merou<gwenhael.goavec-merou@trabucayre.com>
-- Creation date : 2018/06/11
---------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

entity prn20b_presc is
generic (
	CPT_SIZE	: integer := 32
);
port (
	-- Control
	clk_i	  : in  std_logic; -- Main clock
	rst_i	  : in  std_logic; -- Main reset
	prescaler_i : in std_logic_vector(CPT_SIZE-1 downto 0);
	clk_gen_o : out std_logic; -- slow generated clock
	tick_o	  : out std_logic  -- one tick per slow clk
);
end prn20b_presc;

architecture Behavioral of prn20b_presc is
	signal counter : std_logic_vector(CPT_SIZE-1 downto 0);
	signal counter_next : std_logic_vector(CPT_SIZE-1 downto 0);

	signal presc_m1_s : std_logic_vector(CPT_SIZE-1 downto 0);
	signal load_en_s : std_logic;
begin
	clk_gen_o <= '0';

	presc_m1_s <= std_logic_vector(unsigned(prescaler_i)-1);
	counter_next <= std_logic_vector(unsigned(counter) - 1);

	load_en_s <= '1' when counter = (CPT_SIZE-1 downto 0 => '0') else '0';

	tx_clk_gen : process(clk_i)
	begin
		if rising_edge(clk_i) then
			if rst_i = '1' then
				counter <= (others => '0');
			elsif load_en_s = '1' then
				counter <= presc_m1_s;
			else
				--counter <= counter_next;
				counter <= std_logic_vector(unsigned(counter) - 1);
			end if;
		end if;
	end process;

	process(clk_i)
	begin
		if rising_edge(clk_i) then
			tick_o <= load_en_s;
		end if;
	end process;
end Behavioral;

