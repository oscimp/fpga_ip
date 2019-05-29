library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

Entity meanReal is 
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
		data_i		: in std_logic_vector(INPUT_DATA_SIZE-1 downto 0);
		data_en_i	: in std_logic;
		data_clk_i	: in std_logic;
		data_rst_i	: in std_logic;
		-- for the next component
		data_o 		: out std_logic_vector(OUTPUT_DATA_SIZE-1 downto 0);		
		data_clk_o	: out std_logic;
		data_rst_o	: out std_logic;
		data_en_o	: out std_logic
	);
end entity meanReal;

Architecture meanReal_1 of meanReal is
	constant TMP_DATA_SIZE : natural := OUTPUT_DATA_SIZE+SHIFT;
	signal data_resize_s: std_logic_vector(TMP_DATA_SIZE-1 downto 0);

	signal accum_s : std_logic_vector(TMP_DATA_SIZE-1 downto 0);
	signal accum_next_s : std_logic_vector(TMP_DATA_SIZE-1 downto 0);
	signal final_s : std_logic_vector(OUTPUT_DATA_SIZE-1 downto 0);
	signal cpt : natural range 0 to nb_accum-1;
begin
	data_clk_o <= data_clk_i;
	data_rst_o <= data_rst_i;
	signed_prod: if format = "signed" generate
		data_resize_s <= 
			(TMP_DATA_SIZE-1 downto INPUT_DATA_SIZE => data_i(INPUT_DATA_SIZE-1)) &
			data_i;
		accum_next_s <= std_logic_vector(signed(data_resize_s) +
			signed(accum_s));

	end generate signed_prod;

	unsigned_prod: if format /= "signed" generate
		data_resize_s <= (TMP_DATA_SIZE-1 downto INPUT_DATA_SIZE => '0') & data_i;
		accum_next_s <= std_logic_vector(unsigned(data_resize_s) +
			unsigned(accum_s));
	end generate unsigned_prod;

	process(data_clk_i)
	begin
		if rising_edge(data_clk_i) then
			if data_rst_i = '1' then
				accum_s <= (others => '0');
				cpt <= 0;
			else
				accum_s <= accum_s;
				cpt <= cpt;
				if data_en_i = '1' then
					if cpt < nb_accum-1 then
						accum_s <= accum_next_s;
						cpt <= cpt + 1;
					else
						accum_s <= (others => '0');
						cpt <= 0;
					end if;
				end if;
			end if;
		end if;
	end process;

	process(data_clk_i)
	begin
		if rising_edge(data_clk_i) then
			if data_rst_i = '1' then
				final_s <= (others => '0');
				data_en_o <= '0';
			else
				final_s <= final_s;
				data_en_o <= '0';
				if data_en_i = '1' then
					if cpt = nb_accum-1 then
						final_s <= accum_next_s(TMP_DATA_SIZE-1 downto shift);
						data_en_o <= '1';
					end if;
				end if;
			end if;
		end if;
	end process;

	data_o <= final_s;

end architecture meanReal_1;

