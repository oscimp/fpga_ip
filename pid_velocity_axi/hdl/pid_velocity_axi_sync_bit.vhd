---------------------------------------------------------------------------
-- (c) Copyright: OscillatorIMP Digital
-- Author : Gwenhael Goavec-Merou<gwenhael.goavec-merou@trabucayre.com>
-- Creation date : 2015/04/08
---------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity pid_velocity_axi_sync_bit is
	generic (stages : natural := 3);
	port (
		ref_clk_i : in std_logic;
		clk_i : in std_logic;
		bit_i : in std_logic;
		bit_o : out std_logic
	);
end entity pid_velocity_axi_sync_bit;

architecture bhv of pid_velocity_axi_sync_bit is
	signal sync_stage0_s: std_logic;
	signal flipflops : std_logic_vector(stages -1 downto 0) := (others => '0');
	attribute ASYNC_REG : string;
	attribute ASYNC_REG of flipflops: signal is "true";
begin
	ref_proc: process(ref_clk_i) begin
		if rising_edge(ref_clk_i) then
			sync_stage0_s <= bit_i;
		end if;
	end process;

	sync_proc: process(clk_i)
	begin
		if rising_edge(clk_i) then
			flipflops(0) <= sync_stage0_s;
			flipflops(stages-1 downto 1)
				<= flipflops(stages-2 downto 0);
		end if;
	end process;
	bit_o <= flipflops(stages-1);
end bhv;
