---------------------------------------------------------------------------
-- (c) Copyright: OscillatorIMP Digital
-- Author : Gwenhael Goavec-Merou<gwenhael.goavec-merou@trabucayre.com>
-- Creation date : 2015/04/08
---------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity nco_counter_synchronizer_bit is
	generic (stages : natural := 3);
	port (clk_i : in std_logic;
		bit_i : in std_logic;
		bit_o : out std_logic
	);
end entity nco_counter_synchronizer_bit;

architecture bhv of nco_counter_synchronizer_bit is
	signal flipflops : std_logic_vector(stages -1 downto 0) := (others => '0');
	attribute ASYNC_REG : string;
	attribute ASYNC_REG of flipflops: signal is "true";
begin
	bit_o <= flipflops(stages-1);

	sync_proc: process(clk_i)
	begin
		if rising_edge(clk_i) then
			flipflops <= flipflops(stages-2 downto 0) & bit_i;
		end if;
	end process;
end bhv;
