library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity slv_to_sl_axi_sync_slv is
	generic (stages : natural := 3;
		DATA : natural := 16);
	port (clk_i : in std_logic;
		bit_i : in std_logic_vector(DATA-1 downto 0);
		bit_o : out std_logic_vector(DATA-1 downto 0)
	);
end entity slv_to_sl_axi_sync_slv;

architecture bhv of slv_to_sl_axi_sync_slv is
	type data_tab is array (natural range <>) of std_logic_vector(DATA-1 downto 0);
	signal flipflops : data_tab(stages -1 downto 0) := 
		(others => (others => '0'));
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
