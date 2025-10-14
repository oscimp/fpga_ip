---------------------------------------------------------------------------
-- (c) Copyright: Femto Engineering
-- Author: Benoit Dubois <benoit.dubois@femto-engineering.fr>
-- Creation date: 2025/10/14
---------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity combReal is
	generic (
		DIFFERENTIAL_DELAY : natural := 1;
		DATA_SIZE : natural := 16
	);
	port (
		clk : in std_ulogic;
		reset : in std_ulogic;
		data_en_i : in std_ulogic;
		data_i : in signed(DATA_SIZE-1 downto 0);
		data_o : out signed(DATA_SIZE-1 downto 0)
	);
end combReal;

architecture rtl of combReal is
	--
	subtype reg_t is signed(DATA_SIZE-1 downto 0);
	type reg_array_t is array (1 to DIFFERENTIAL_DELAY) of reg_t;
	--
	signal delayed_data_s : reg_array_t := (others => (others => '0'));
	signal comb_out_s     : signed(DATA_SIZE-1 downto 0) := (others => '0');
begin

	process(clk)
	begin
		if reset = '1' then
			comb_out_s <= (others => '0');
			delayed_data_s <= (others => (others => '0'));
		elsif (rising_edge(clk)) then
			if (data_en_i = '1') then
				comb_out_s <= data_i - delayed_data_s(DIFFERENTIAL_DELAY);
				if DIFFERENTIAL_DELAY > 1 then
					for i in 2 to DIFFERENTIAL_DELAY loop
						delayed_data_s(i) <= delayed_data_s(i-1);
					end loop;
				end if;
				delayed_data_s(1) <= data_i;
			end if;	
		end if;
	end process;

	data_o <= comb_out_s;

end rtl;
