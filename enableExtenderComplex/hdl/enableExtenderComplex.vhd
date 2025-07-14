library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

Entity enableExtenderComplex is 
	generic (
		DATA_SIZE : natural := 16;
		COUNTER_SIZE : natural := 2;
		USE_EOF : boolean := false
	);
	port (
		-- input data
		data_i_i : in std_logic_vector(DATA_SIZE-1 downto 0);
		data_q_i : in std_logic_vector(DATA_SIZE-1 downto 0);
		data_en_i: in std_logic;
		data_rst_i: in std_logic;
		data_clk_i: in std_logic;
		data_eof_i: in std_logic;
		-- output data
		data_i_o  : out std_logic_vector(DATA_SIZE-1 downto 0);
		data_q_o  : out std_logic_vector(DATA_SIZE-1 downto 0);
		data_en_o : out std_logic;
		data_rst_o : out std_logic;
		data_clk_o : out std_logic;
		data_eof_o : out std_logic;
		extended_data_en_o : out std_logic
	);
end entity;

Architecture enableExtenderComplex_1 of enableExtenderComplex is
	signal cpt_s : std_logic_vector(COUNTER_SIZE-1 downto 0);
	signal extended_data_en_s, start_s : std_logic;

begin
	data_i_o <= data_i_i;
	data_q_o <= data_q_i;
	data_en_o <= data_en_i;
	data_rst_o <= data_rst_i;
	data_clk_o <= data_clk_i;
	data_eof_o <= data_eof_i;

	extended_data_en_o <= extended_data_en_s;

	eof_extender: if USE_EOF = true generate
		start_s <= data_eof_i;
	end generate;
	en_extender: if USE_EOF = false generate
		start_s <= data_en_i;
	end generate;

	process(data_clk_i)
	begin
		if rising_edge(data_clk_i) then
			if data_rst_i = '1' then
				extended_data_en_s <= '0';
				cpt_s <= std_logic_vector(to_unsigned(0, COUNTER_SIZE));
			else
				cpt_s <= cpt_s;
				extended_data_en_s <= extended_data_en_s;
				if start_s = '1' then
					if extended_data_en_s = '0' then
						extended_data_en_s <= '1';
						--cpt_s <= std_logic_vector(unsigned(cpt_s) + 1);
					end if;
				end if;
			end if;

			if extended_data_en_s = '1' then
				if cpt_s < ((COUNTER_SIZE-1 downto 0 => '1')) then
					cpt_s <= std_logic_vector(unsigned(cpt_s) + 1);
				else
					cpt_s <= std_logic_vector(to_unsigned(0, COUNTER_SIZE));
					extended_data_en_s <= '0';
				end if;
			end if;
		end if;
	end process;

end architecture enableExtenderComplex_1;
