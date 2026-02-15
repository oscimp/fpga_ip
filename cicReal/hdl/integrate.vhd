---------------------------------------------------------------------------
-- (c) Copyright: FemtoEngineering
-- Author : Benoit Dubois <benoit.dubois@femto-engineering.fr>
-- Creation date : 2024/04/15
---------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity integrator is
	generic (
		DATA_SIZE : natural := 16
	);
	port (
		clk : in std_ulogic;
		data_i : in signed(DATA_SIZE-1 downto 0);
		data_o : out signed(DATA_SIZE-1 downto 0)
	);
end integrator;

architecture A of integrator is	
	signal int_r   : signed(DATA_SIZE-1 downto 0) := (others => '0');
	signal int_out : signed(DATA_SIZE-1 downto 0) := (others => '0');
begin

	process(clk)
	begin
		if (rising_edge(clk)) then
			int_r <= data_i;
			int_out <= int_r + int_out;
		end if;
	end process;
				
	data_o <= int_out;
end A;
