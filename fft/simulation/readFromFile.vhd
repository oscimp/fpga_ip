library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
USE std.textio.ALL;
--use work.sp_vision_test_pkg.all;

entity readFromFile is
generic (
	DATA_SIZE : natural := 16;
	ADDR_SIZE : natural := 10;
	filename : string := ""
);
port (
	reset : in std_logic;
	clk : in std_logic;
	sl_clk_i : in std_logic;
	--fichier : in text;

	start_read_i : in std_logic;
	data_o : out std_logic_vector(DATA_SIZE-1 downto 0);
	addr_o : out std_logic_vector(ADDR_SIZE-1 downto 0);
	data_en_o : out std_logic;
	end_of_read_o : out std_logic
);
end entity readFromFile;

architecture RTL of readFromFile is
	file fichier: text open read_mode is filename;
	signal counter_s : natural range 0 to 2**ADDR_SIZE-1;
	signal read_data_val_s : std_logic_vector(DATA_SIZE-1 downto 0);
	signal read_data_en_s : std_logic;
	signal end_read_s : std_logic;
	signal fin_s : std_logic;
begin
	data_o <= read_data_val_s;
	addr_o <= std_logic_vector(to_unsigned(counter_s,ADDR_SIZE));
	data_en_o <= read_data_en_s;
	end_of_read_o <= end_read_s;

	read_data : process(clk, reset)
		variable vectorline : line;
		variable content : integer;
	begin
		if (reset = '1') then
			read_data_en_s <= '0';
			read_data_val_s <= (others => '0');
			read_data_val_s <= (others => '0');
			end_read_s <= '0';
		elsif rising_edge(clk) then
			end_read_s <= end_read_s;
			read_data_en_s <= '0';
          	if sl_clk_i = '1' and start_read_i = '1' then     
				if (not endfile(fichier)) and fin_s = '0' then
					readline(fichier, vectorline);
					read(vectorline, content);
					read_data_val_s <= std_logic_vector(to_signed(content,DATA_SIZE));
					read_data_en_s <= '1';
				else 
					end_read_s <= '1';
				end if;
			end if;
		end if;
	end process; 
	
	counter_coeff_storage : process(clk, reset)
	begin
		if reset = '1' then
			counter_s <= 0;
			fin_s <= '0';
		elsif rising_edge(clk) then
			fin_s <= fin_s;
			counter_s <= counter_s;
			if read_data_en_s = '1' then
				if counter_s < 2**ADDR_SIZE-1 then
					counter_s <= counter_s + 1;
				else
					counter_s <= 0;
					fin_s <= '1';
    	 		end if;
     		end if;
		end if;
	end process;

end architecture RTL;
