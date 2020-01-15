library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity dataReal_dma_direct_sync is
	generic (stages : natural := 3);
	port (clk_i : in std_logic;
		bit_i : in std_logic;
		bit_o : out std_logic
	);
end entity dataReal_dma_direct_sync;

architecture bhv of dataReal_dma_direct_sync is
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
