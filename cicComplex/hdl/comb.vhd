---------------------------------------------------------------------------
-- (c) Copyright: Femto Engineering
-- Author: Benoit Dubois <benoit.dubois@femto-engineering.fr>
-- Creation date: 2024/04/15
---------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity comb is
	generic (
		DIFFERENTIAL_DELAY : natural := 1;
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
end comb;

architecture rtl of comb is
	--
	subtype reg_t is signed(DATA_SIZE-1 downto 0);
	type reg_array_t is array (1 to DIFFERENTIAL_DELAY) of reg_t;
	--
	signal delayed_data_i_s : reg_array_t := (others => (others => '0'));
	signal comb_out_i_s     : signed(DATA_SIZE-1 downto 0) := (others => '0');
	--
	signal delayed_data_q_s : reg_array_t := (others => (others => '0'));
	signal comb_out_q_s     : signed(DATA_SIZE-1 downto 0) := (others => '0');
begin

	process(clk)
	begin
		if reset = '1' then
			comb_out_i_s <= (others => '0');
			delayed_data_i_s <= (others => (others => '0'));
		elsif (rising_edge(clk)) then
			if (data_en_i = '1') then
				comb_out_i_s <= data_i_i - delayed_data_i_s(DIFFERENTIAL_DELAY);
				if DIFFERENTIAL_DELAY > 1 then
					for i in 2 to DIFFERENTIAL_DELAY loop
						delayed_data_i_s(i) <= delayed_data_i_s(i-1);
					end loop;
				end if;
				delayed_data_i_s(1) <= data_i_i;
			end if;	
		end if;
	end process;


	process(clk)
	begin
		if reset = '1' then
			comb_out_q_s <= (others => '0');
			delayed_data_q_s <= (others => (others => '0'));
		elsif (rising_edge(clk)) then
			if (data_en_i = '1') then
				comb_out_q_s <= data_q_i - delayed_data_q_s(DIFFERENTIAL_DELAY);
				if DIFFERENTIAL_DELAY > 1 then
					for i in 2 to DIFFERENTIAL_DELAY loop
						delayed_data_q_s(i) <= delayed_data_q_s(i-1);
					end loop;
				end if;
				delayed_data_q_s(1) <= data_q_i;
			end if;	
		end if;
	end process;

	data_i_o <= comb_out_i_s;
	data_q_o <= comb_out_q_s;

end rtl;
