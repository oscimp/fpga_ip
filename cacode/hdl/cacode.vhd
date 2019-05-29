library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

entity cacode is
	generic (
		PERIOD_LEN : natural := 1
	);
 	port (
		clk : in std_logic;
		reset : in std_logic;
		tick_i : in std_logic;
		-- start
		g1_full_o : out std_logic_vector(9 downto 0);
		cacode_o : out std_logic_vector(9 downto 0);
		g1_o : out std_logic;
		g2_o : out std_logic;
		gold_code_o : out std_logic_vector(31 downto 0)
	);
end entity;
 
architecture rtl of cacode is
	signal g2_full_s : std_logic_vector(9 downto 0);
	signal g1_s : std_logic;
	signal s1_s, s2_s, s1_2_s : std_logic_vector(31 downto 0);

	-- prescaler
	signal counter_s, counter_next_s : natural range 0 to PERIOD_LEN-1;
	signal tick_s : std_logic;
	signal load_en_s : std_logic;
begin
	process(clk) begin
		if rising_edge(clk) then
			cacode_o <= g2_full_s;
		end if;
	end process;

	g1_o <= g1_s;

	gen_g1_inst : entity work.cacode_g1_gen
	port map (clk => clk, reset => reset, tick_i => tick_s,
		prn_o => g1_full_o, bit_o => g1_s
	);

	gen_g2_inst : entity work.cacode_g2_gen
	port map (clk => clk, reset => reset, tick_i => tick_s,
		prn_o => g2_full_s, bit_o => g2_o
	);

	gold_loop: for id in 1 to 32 generate
		gold_code_o(id-1) <= s1_2_s(id-1) xor g1_s;
		s1_2_s(id-1) <= s1_s(id-1) xor s2_s(id-1);
	
		id_0 : if id = 1 generate
			s1_s(id-1) <= g2_full_s(1);
			s2_s(id-1) <= g2_full_s(5);
		end generate id_0;

		id_1_4 : if id > 0 and id < 5 generate
			s1_s(id-1) <= g2_full_s(id);
			s2_s(id-1) <= g2_full_s(id+4);
		end generate id_1_4;
		id_5_6 : if id >= 5 and id < 7 generate
			s1_s(id-1) <= g2_full_s(id-5);
			s2_s(id-1) <= g2_full_s(id+3);
		end generate id_5_6;
		id_7_9 : if id >= 7 and id < 10 generate
			s1_s(id-1) <= g2_full_s(id-7);
			s2_s(id-1) <= g2_full_s(id);
		end generate id_7_9;
		id_10_11 : if id >= 10 and id < 12 generate
			s1_s(id-1) <= g2_full_s(id-9);
			s2_s(id-1) <= g2_full_s(id-8);
		end generate id_10_11;
		id_12_16 : if id >= 12 and id < 17 generate
			s1_s(id-1) <= g2_full_s(id-8);
			s2_s(id-1) <= g2_full_s(id-7);
		end generate id_12_16;
		id_17_22 : if id >= 17 and id < 23 generate
			s1_s(id-1) <= g2_full_s(id-17);
			s2_s(id-1) <= g2_full_s(id-14);
		end generate id_17_22;
		id_23 : if id = 23 generate
			s1_s(id-1) <= g2_full_s(id-23);
			s2_s(id-1) <= g2_full_s(id-21);
		end generate id_23;
		id_24_28 : if id >= 24 and id < 29 generate
			s1_s(id-1) <= g2_full_s(id-21);
			s2_s(id-1) <= g2_full_s(id-19);
		end generate id_24_28;
		id_29_32 : if id >= 29 and id < 33 generate
			s1_s(id-1) <= g2_full_s(id-29);
			s2_s(id-1) <= g2_full_s(id-24);
		end generate id_29_32;
	end generate gold_loop;

	not_presc : if PERIOD_LEN = 1 generate
		tick_s <= tick_i;
	end generate not_presc;

	use_presc : if PERIOD_LEN > 1 generate
		counter_next_s <= PERIOD_LEN-1 when counter_s = 0 else counter_s - 1;

		load_en_s <= '1' when counter_s = 0 else '0';

		tx_clk_gen : process(clk)
		begin
			if rising_edge(clk) then
				if reset = '1' then
					counter_s <= PERIOD_LEN-1;
				elsif tick_i = '1' then
					counter_s <= counter_next_s;
				else
					counter_s <= counter_s;
				end if;
			end if;
		end process;

		process(clk)
		begin
			if rising_edge(clk) then
				tick_s <= load_en_s;
			end if;
		end process;
	end generate use_presc;

end architecture rtl;
