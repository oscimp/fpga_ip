library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

Entity clkChangeComplex is 
	generic (
		DATA_SIZE : natural := 32
	);
	port 
	(
		ref_clk_i : in std_logic;
		rst_i 		: in std_logic;
		-- input data
		data_i_i : in std_logic_vector(DATA_SIZE-1 downto 0);
		data_q_i : in std_logic_vector(DATA_SIZE-1 downto 0);
		data_en_i: in std_logic;
		data_eof_i: in std_logic;
		data_clk_i: in std_logic;

		-- for the next component
		data_q_o  : out std_logic_vector(DATA_SIZE-1 downto 0);		
		data_i_o  : out std_logic_vector(DATA_SIZE-1 downto 0);		
		data_en_o : out std_logic;
		data_eof_o : out std_logic;
		data_clk_o : out std_logic
	);
end entity;
Architecture clkChangeComplex_1 of clkChangeComplex is
	signal data_q_s, data_i_s : std_logic_vector(DATA_SIZE-1 downto 0);
	signal data_q_out_s, data_i_out_s : std_logic_vector(DATA_SIZE-1 downto 0);
	signal ack_s, data_eof_s, data_en_s : std_logic;
begin
	data_clk_o <= ref_clk_i;

	process(data_clk_i)
	begin
		if rising_edge(data_clk_i) then
			data_q_s <= data_q_s;
			data_i_s <= data_i_s;
			data_en_s <= data_en_s;
			data_eof_s <= data_eof_s;
			if rst_i = '1' then
				data_q_s <= (others => '0');
				data_i_s <= (others => '0');
				data_en_s <= '0';
				data_eof_s <= '0';
			end if;

			if data_en_i = '1' then
				data_q_s <= data_q_i;
				data_i_s <= data_i_i;
				data_eof_s <= data_eof_i;
				data_en_s <= data_en_i;
			end if;

			if ack_s = '1' then
				data_eof_s <= '0';
				data_en_s <= '0';
			end if;
		end if;
	end process;

	data_q_o <= data_q_out_s;
	data_i_o <= data_i_out_s;

	process(ref_clk_i)
	begin
		if rising_edge(ref_clk_i) then
			data_i_out_s <= data_i_out_s;
			data_q_out_s <= data_q_out_s;
			data_en_o <= '0';
			data_eof_o <= '0';
			ack_s <= '0';
			if data_en_s = '1' then
				data_i_out_s <= data_i_s;
				data_q_out_s <= data_q_s;
				data_en_o <= data_en_s;
				data_eof_o <= data_eof_s;
				ack_s <= '1';
			end if;
		end if;
	end process;

end architecture clkChangeComplex_1;

