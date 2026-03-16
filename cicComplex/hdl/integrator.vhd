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
		reset : in std_ulogic;
		data_en_i : in std_ulogic;
		data_i_i : in signed(DATA_SIZE-1 downto 0);
		data_q_i : in signed(DATA_SIZE-1 downto 0);
		data_i_o : out signed(DATA_SIZE-1 downto 0);
		data_q_o : out signed(DATA_SIZE-1 downto 0)
	);
end integrator;

architecture rtl of integrator is	
	--
	signal int_out_i_s : signed(DATA_SIZE-1 downto 0) := (others => '0');
	signal int_i_s : signed(DATA_SIZE-1 downto 0) := (others => '0');
	--
	signal int_out_q_s : signed(DATA_SIZE-1 downto 0) := (others => '0');
	signal int_q_s : signed(DATA_SIZE-1 downto 0) := (others => '0');
begin

	process(clk)
	begin
		if reset = '1' then
			int_i_s <= (others => '0');
			int_out_i_s <= (others => '0');
		elsif (rising_edge(clk)) then
			if (data_en_i = '1') then
				int_i_s <= data_i_i;
				int_out_i_s <= int_out_i_s + data_i_i;
			end if;
		end if;
	end process;

	process(clk)
	begin
		if reset = '1' then
			int_q_s <= (others => '0');
			int_out_q_s <= (others => '0');
		elsif (rising_edge(clk)) then
			if (data_en_i = '1') then
				int_q_s <= data_q_i;
				int_out_q_s <= int_out_q_s + data_q_i;
			end if;
		end if;
	end process;
				
	data_i_o <= int_out_i_s;
	data_q_o <= int_out_q_s;

end rtl;
