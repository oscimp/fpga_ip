library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

Entity decimComplex_axi_logic is 
	generic (
		DECIM_SIZE : natural := 8;
		DATA_SIZE: natural := 18
	);
	port 
	(
		decim_i		: in std_logic_vector(DECIM_SIZE-1 downto 0);
		-- input data
		data_i_i	: in std_logic_vector(DATA_SIZE-1 downto 0);
		data_q_i	: in std_logic_vector(DATA_SIZE-1 downto 0);
		data_en_i	: in std_logic;
		data_clk_i	: in std_logic;
		data_rst_i	: in std_logic;
		-- for the next component
		data_i_o	: out std_logic_vector(DATA_SIZE-1 downto 0);		
		data_q_o	: out std_logic_vector(DATA_SIZE-1 downto 0);		
		data_clk_o	: out std_logic;
		data_rst_o	: out std_logic;
		data_en_o	: out std_logic
	);
end entity decimComplex_axi_logic;

Architecture bhv of decimComplex_axi_logic is
	constant DECIM_MAX: natural := 2**DECIM_SIZE;

	signal data_next_i_s: std_logic_vector(DATA_SIZE-1 downto 0);
	signal data_next_q_s: std_logic_vector(DATA_SIZE-1 downto 0);
	signal data_i_s: std_logic_vector(DATA_SIZE-1 downto 0);
	signal data_q_s: std_logic_vector(DATA_SIZE-1 downto 0);
	signal final_i_s: std_logic_vector(DATA_SIZE-1 downto 0);
	signal final_q_s: std_logic_vector(DATA_SIZE-1 downto 0);

	signal cpt : natural range 0 to DECIM_MAX-1;
begin
	data_clk_o <= data_clk_i;
	data_rst_o <= data_rst_i;
	data_next_i_s <= data_i_i;
	data_next_q_s <= data_q_i;

	process(data_clk_i)
	begin
		if rising_edge(data_clk_i) then
			if data_rst_i = '1' then
				data_i_s <= (others => '0');
				data_q_s <= (others => '0');
				cpt <= 0;
			else
				data_i_s <= data_i_s;
				data_q_s <= data_q_s;
				cpt <= cpt;
				if data_en_i = '1' then
					if cpt < unsigned(decim_i)-1 then
						data_i_s <= data_next_i_s;
						data_q_s <= data_next_q_s;
						cpt <= cpt + 1;
					else
						data_i_s <= (others => '0');
						data_q_s <= (others => '0');
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
				final_i_s <= (others => '0');
				final_q_s <= (others => '0');
				data_en_o <= '0';
			else
				final_i_s <= final_i_s;
				final_q_s <= final_q_s;
				data_en_o <= '0';
				if data_en_i = '1' then
					if cpt = unsigned(decim_i)-1 then
						final_i_s <= data_next_i_s;
						final_q_s <= data_next_q_s;
						data_en_o <= '1';
					end if;
				end if;
			end if;
		end if;
	end process;

	data_i_o <= final_i_s;
	data_q_o <= final_q_s;

end architecture bhv;
