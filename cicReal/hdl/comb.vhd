---------------------------------------------------------------------------
-- (c) Copyright: FemtoEngineering
-- Author : Benoit Dubois <benoit.dubois@femto-engineering.fr>
-- Creation date : 2024/04/15
---------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity comb is
	generic (
		DATA_SIZE : natural := 16
	);
	port (
		clk : in std_ulogic;
		data_i : in signed(DATA_SIZE-1 downto 0);
		data_o : out signed(DATA_SIZE-1 downto 0);
		sample_i : in std_ulogic
	);
end comb;

architecture A of comb is
	signal comb_r       : signed(DATA_SIZE-1 downto 0) := (others => '0');
	signal comb_delay_r : signed(DATA_SIZE-1 downto 0) := (others => '0');
	signal comb_out     : signed(DATA_SIZE-1 downto 0) := (others => '0');
begin

	process(clk)
		variable comb_r_v : signed(DATA_SIZE-1 downto 0) := (others => '0');
	begin
		if (rising_edge(clk)) then
			if (sample_i = '1') then
				comb_r_v := data_i;
				comb_delay_r <= comb_r_v;
				comb_out <= comb_r_v - comb_delay_r;
			end if;	
		end if;
	end process;
				
	data_o <= comb_out;

end A;
