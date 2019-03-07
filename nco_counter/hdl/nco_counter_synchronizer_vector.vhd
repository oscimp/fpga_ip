---------------------------------------------------------------------------
-- (c) Copyright: OscillatorIMP Digital
-- Author : Gwenhael Goavec-Merou<gwenhael.goavec-merou@trabucayre.com>
-- Creation date : 2015/04/08
---------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity nco_counter_synchronizer_vector is
	generic (stages : natural := 3;
		DATA : natural := 16);
	port (
		ref_clk_i : in std_logic;
		clk_i : in std_logic;
		bit_i : in std_logic_vector(DATA-1 downto 0);
		bit_o : out std_logic_vector(DATA-1 downto 0)
	);
end entity nco_counter_synchronizer_vector;

architecture bhv of nco_counter_synchronizer_vector is
	signal sync_vect_stage0_s: std_logic_vector(DATA-1 downto 0);
	type data_tab is array (natural range <>) of std_logic_vector(DATA-1 downto 0);
	signal flipflops_vect : data_tab(stages -1 downto 0) := (others => (others => '0'));
	attribute ASYNC_REG : string;
	attribute ASYNC_REG of flipflops_vect: signal is "true";
begin
	ref_proc: process(ref_clk_i) begin
		if rising_edge(ref_clk_i) then
			sync_vect_stage0_s <= bit_i;
		end if;
	end process;

	sync_proc: process(clk_i)
	begin
		if rising_edge(clk_i) then
			flipflops_vect(0) <= sync_vect_stage0_s;
			flipflops_vect(stages-1 downto 1)
				<= flipflops_vect(stages-2 downto 0);
		end if;
	end process;
	bit_o <= flipflops_vect(stages-1);
end bhv;
