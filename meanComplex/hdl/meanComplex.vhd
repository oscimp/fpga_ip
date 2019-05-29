library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

Entity meanComplex is 
	generic (
		format : string := "signed";
		nb_accum : natural := 8;
		shift : natural := 3;
		OUTPUT_DATA_SIZE: natural := 18;
		INPUT_DATA_SIZE : natural := 16
	);
	port 
	(
		-- input data
		data_i_i	: in std_logic_vector(INPUT_DATA_SIZE-1 downto 0);
		data_q_i	: in std_logic_vector(INPUT_DATA_SIZE-1 downto 0);
		data_en_i	: in std_logic;
		data_clk_i	: in std_logic;
		data_rst_i	: in std_logic;
		-- for the next component
		data_i_o	: out std_logic_vector(OUTPUT_DATA_SIZE-1 downto 0);		
		data_q_o	: out std_logic_vector(OUTPUT_DATA_SIZE-1 downto 0);		
		data_clk_o	: out std_logic;
		data_rst_o	: out std_logic;
		data_en_o	: out std_logic
	);
end entity meanComplex;

Architecture meanComplex_1 of meanComplex is
	constant TMP_DATA_SIZE : natural := OUTPUT_DATA_SIZE+SHIFT;
	signal data_i_resize_s: std_logic_vector(TMP_DATA_SIZE-1 downto 0);
	signal data_q_resize_s: std_logic_vector(TMP_DATA_SIZE-1 downto 0);

	signal accum_i_s : std_logic_vector(TMP_DATA_SIZE-1 downto 0);
	signal accum_q_s : std_logic_vector(TMP_DATA_SIZE-1 downto 0);
	signal accum_next_i_s : std_logic_vector(TMP_DATA_SIZE-1 downto 0);
	signal accum_next_q_s : std_logic_vector(TMP_DATA_SIZE-1 downto 0);
	signal final_i_s : std_logic_vector(OUTPUT_DATA_SIZE-1 downto 0);
	signal final_q_s : std_logic_vector(OUTPUT_DATA_SIZE-1 downto 0);
	signal cpt : natural range 0 to nb_accum-1;
begin
	data_clk_o <= data_clk_i;
	data_rst_o <= data_rst_i;
	signed_prod: if format = "signed" generate
		data_i_resize_s <= 
			(TMP_DATA_SIZE-1 downto INPUT_DATA_SIZE => data_i_i(INPUT_DATA_SIZE-1)) &
			data_i_i;
		data_q_resize_s <= 
			(TMP_DATA_SIZE-1 downto INPUT_DATA_SIZE => data_q_i(INPUT_DATA_SIZE-1)) &
			data_q_i;
		accum_next_i_s <= std_logic_vector(signed(data_i_resize_s) +
			signed(accum_i_s));
		accum_next_q_s <= std_logic_vector(signed(data_q_resize_s) +
			signed(accum_q_s));

	end generate signed_prod;

	unsigned_prod: if format /= "signed" generate
		data_i_resize_s <= (TMP_DATA_SIZE-1 downto INPUT_DATA_SIZE => '0') & data_i_i;
		data_q_resize_s <= (TMP_DATA_SIZE-1 downto INPUT_DATA_SIZE => '0') & data_q_i;
		accum_next_i_s <= std_logic_vector(unsigned(data_i_resize_s) +
			unsigned(accum_i_s));
		accum_next_q_s <= std_logic_vector(unsigned(data_q_resize_s) +
			unsigned(accum_q_s));
	end generate unsigned_prod;

	process(clk_i)
	begin
		if rising_edge(clk_i) then
			if data_rst_i = '1' then
				accum_i_s <= (others => '0');
				accum_q_s <= (others => '0');
				cpt <= 0;
			else
				accum_i_s <= accum_i_s;
				accum_q_s <= accum_q_s;
				cpt <= cpt;
				if data_en_i = '1' then
					if cpt < nb_accum-1 then
						accum_i_s <= accum_next_i_s;
						accum_q_s <= accum_next_q_s;
						cpt <= cpt + 1;
					else
						accum_i_s <= (others => '0');
						accum_q_s <= (others => '0');
						cpt <= 0;
					end if;
				end if;
			end if;
		end if;
	end process;

	process(clk_i)
	begin
		if rising_edge(clk_i) then
			if data_rst_i = '1' then
				final_i_s <= (others => '0');
				final_q_s <= (others => '0');
				data_en_o <= '0';
			else
				final_i_s <= final_i_s;
				final_q_s <= final_q_s;
				data_en_o <= '0';
				if data_en_i = '1' then
					if cpt = nb_accum-1 then
						final_i_s <= accum_next_i_s(TMP_DATA_SIZE-1 downto shift);
						final_q_s <= accum_next_q_s(TMP_DATA_SIZE-1 downto shift);
						data_en_o <= '1';
					end if;
				end if;
			end if;
		end if;
	end process;

	data_i_o <= final_i_s;
	data_q_o <= final_q_s;

end architecture meanComplex_1;

