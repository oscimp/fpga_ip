library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
USE std.textio.ALL;
--use work.sp_vision_test_pkg.all;

entity readComplexFromFile is
generic (
	DATA_SIZE : natural := 16;
	ADDR_SIZE : natural := 10;
	filename_re : string := "";
	filename_im : string := ""
);
port (
	reset : in std_logic;
	clk : in std_logic;
	sl_clk_i : in std_logic;
	--fichier : in text;

	start_read_i : in std_logic;
	data_re_o : out std_logic_vector(DATA_SIZE-1 downto 0);
	data_im_o : out std_logic_vector(DATA_SIZE-1 downto 0);
	addr_o : out std_logic_vector(ADDR_SIZE-1 downto 0);
	data_en_o : out std_logic;
	end_of_read_o : out std_logic
);
end entity readComplexFromFile;

architecture RTL of readComplexFromFile is
	file fichier_re : text open read_mode is filename_re;
	file fichier_im : text open read_mode is filename_im;
	signal counter_s : natural range 0 to 2**ADDR_SIZE-1;
	signal read_data_re_val_s : std_logic_vector(DATA_SIZE-1 downto 0);
	signal read_data_im_val_s : std_logic_vector(DATA_SIZE-1 downto 0);
	signal read_data_en_s : std_logic;
	signal end_read_s : std_logic;
	signal fin_s : std_logic;
begin
	data_re_o <= read_data_re_val_s;
	data_im_o <= read_data_im_val_s;
	addr_o <= std_logic_vector(to_unsigned(counter_s,ADDR_SIZE));
	data_en_o <= read_data_en_s;
	end_of_read_o <= end_read_s;

	read_data : process(clk, reset)
		variable vectorline_re : line;
		variable content_re : integer;
		variable vectorline_im : line;
		variable content_im : integer;
		variable test_l : line;
	begin
		if (reset = '1') then
			read_data_en_s <= '0';
			read_data_re_val_s <= (others => '0');
			read_data_im_val_s <= (others => '0');
			end_read_s <= '0';
		elsif rising_edge(clk) then
			end_read_s <= end_read_s;
			read_data_en_s <= '0';
			read_data_re_val_s <= read_data_re_val_s;
			read_data_im_val_s <= read_data_im_val_s;
          	if sl_clk_i = '1' and start_read_i = '1' then     
				if (not endfile(fichier_re)) then --and fin_s = '0' then
					readline(fichier_re, vectorline_re);
					read(vectorline_re, content_re);
					--write(test_l, integer'image(content_re));
					--writeline(OUTPUT, test_l);
					read_data_re_val_s <=
					std_logic_vector(to_signed(content_re,read_data_re_val_s'length));
					readline(fichier_im, vectorline_im);
					read(vectorline_im, content_im);
					read_data_im_val_s <= std_logic_vector(to_signed(content_im,DATA_SIZE));
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
			counter_s <= counter_s;
			fin_s <= fin_s;
			if read_data_en_s = '1' then
				if counter_s < 2**ADDR_SIZE-1 then
					counter_s <= counter_s + 1;
				else
					fin_s <= '1';
					counter_s <= 0;
    	 		end if;
     		end if;
		end if;
	end process;

end architecture RTL;
