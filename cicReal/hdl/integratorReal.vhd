---------------------------------------------------------------------------
-- (c) Copyright: FemtoEngineering
-- Author : Benoit Dubois <benoit.dubois@femto-engineering.fr>
-- Creation date : 2025/10/14
---------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity integratorReal is
	generic (
		DATA_SIZE : natural := 16
	);
	port (
		clk : in std_ulogic;
		reset : in std_ulogic;
		data_en_i : in std_ulogic;
		data_i : in signed(DATA_SIZE-1 downto 0);
		data_o : out signed(DATA_SIZE-1 downto 0)
	);
end integratorReal;

architecture rtl of integratorReal is	
	signal int_out_s : signed(DATA_SIZE-1 downto 0) := (others => '0');
	signal int_s : signed(DATA_SIZE-1 downto 0) := (others => '0');
begin

	process(clk)
	begin
		if reset = '1' then
			int_s <= (others => '0');
			int_out_s <= (others => '0');
		elsif (rising_edge(clk)) then
			if (data_en_i = '1') then
				int_s <= data_i;
				int_out_s <= int_out_s + data_i;
			end if;
		end if;
	end process;

	data_o <= int_out_s;

end rtl;
