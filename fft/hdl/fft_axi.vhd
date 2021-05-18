library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fft_axi is
	generic (
		COEFF_SIZE : natural := 16;
		ADDR_SIZE : natural := 10;
		-- Width of S_AXI data bus
		C_S_AXI_DATA_WIDTH	: integer	:= 32
	);
	port (
		S_AXI_ACLK	: in std_logic;
		reset		: in std_logic;
		addr_i	  : in std_logic_vector(1 downto 0);
		write_en_i	: in std_logic;
		writedata	: in std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		read_en_i : in std_logic;
		read_ack_o : out std_logic;
		readdata	: out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);--;
		read_coeff_re_i : in std_logic_vector(COEFF_SIZE-1 downto 0);
		read_coeff_im_i : in std_logic_vector(COEFF_SIZE-1 downto 0);
		data_i : in std_logic_vector(31 downto 0);
		data_addr_o : out std_logic_vector(ADDR_SIZE -1 downto 0);
		-- end of test
		coeff_re_en_o : out std_logic;
		coeff_re_val_o : out std_logic_vector(COEFF_SIZE-1 downto 0);
		coeff_re_addr_o : out std_logic_vector(ADDR_SIZE-1 downto 0);
		coeff_im_en_o : out std_logic;
		coeff_im_val_o : out std_logic_vector(COEFF_SIZE-1 downto 0);
		coeff_im_addr_o : out std_logic_vector(ADDR_SIZE-1 downto 0)
	);
end fft_axi;

architecture arch_imp of fft_axi is
	constant REG_ID	 : std_logic_vector(1 downto 0) := "00";
	constant REG_RE_COEFF : std_logic_vector(1 downto 0) := "01";
	constant REG_IM_COEFF : std_logic_vector(1 downto 0) := "10";
	constant REG_DATA : std_logic_vector(1 downto 0) := "11";

	signal readdata_s	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal coeff_re_en_s, coeff_im_en_s : std_logic;
	signal coeff_re_val_s  : std_logic_vector(COEFF_SIZE-1 downto 0);
	signal coeff_im_val_s  : std_logic_vector(COEFF_SIZE-1 downto 0);
	signal coeff_re_addr_s, coeff_im_addr_s : std_logic_vector(ADDR_SIZE-1 downto 0);
	signal coeff_re_addr_next_s : std_logic_vector(ADDR_SIZE-1 downto 0);
	signal coeff_im_addr_next_s : std_logic_vector(ADDR_SIZE-1 downto 0);
	signal read_addr_im_s, read_addr_re_s : std_logic_vector(ADDR_SIZE-1 downto 0);
	signal data_addr_s : std_logic_vector(ADDR_SIZE-1 downto 0);
begin
	data_addr_o <= data_addr_s;

	coeff_re_en_o <= coeff_re_en_s;
	coeff_im_en_o <= coeff_im_en_s;
	coeff_re_val_o <= coeff_re_val_s;
	coeff_im_val_o <= coeff_im_val_s;
	coeff_re_addr_o <= coeff_re_addr_s when coeff_re_en_s = '1' 
		else read_addr_re_s;
	coeff_im_addr_o <= coeff_im_addr_s when coeff_im_en_s = '1'
		else read_addr_im_s;
	readdata <= readdata_s;

	write_process : process (S_AXI_ACLK)
	begin
		if rising_edge(S_AXI_ACLK) then 
			if  reset = '1' then
				coeff_re_en_s <= '0';
				coeff_re_val_s <= (others => '0');
				coeff_re_addr_s <= (others => '0');
				coeff_re_addr_next_s <= (others => '0');
				coeff_im_en_s <= '0';
				coeff_im_val_s <= (others => '0');
				coeff_im_addr_s <= (others => '0');
				coeff_im_addr_next_s <= (others => '0');
			else
				coeff_re_en_s <= '0';
				coeff_re_val_s <= coeff_re_val_s;
				coeff_re_addr_s <= coeff_re_addr_s;
				coeff_re_addr_next_s <= coeff_re_addr_next_s;
				coeff_im_en_s <= '0';
				coeff_im_val_s <= coeff_im_val_s;
				coeff_im_addr_s <= coeff_im_addr_s;
				coeff_im_addr_next_s <= coeff_im_addr_next_s;
				if (write_en_i = '1') then
					case addr_i is --write_addr is
					when REG_ID =>
						coeff_re_addr_s <= (others => '0');
						coeff_re_addr_next_s <= (others => '0');
						coeff_im_addr_s <= (others => '0');
						coeff_im_addr_next_s <= (others => '0');
					WHEN REG_IM_COEFF =>
						coeff_im_en_s <= '1';
						coeff_im_val_s <= writedata(COEFF_SIZE-1 downto 0);
						coeff_im_addr_s <= coeff_im_addr_next_s;
						coeff_im_addr_next_s <= 
								std_logic_vector(unsigned(coeff_im_addr_next_s)+1);
					when REG_RE_COEFF =>
						coeff_re_en_s <= '1';
						coeff_re_val_s <= writedata(COEFF_SIZE-1 downto 0);
						coeff_re_addr_s <= coeff_re_addr_next_s;
						coeff_re_addr_next_s <= 
								std_logic_vector(unsigned(coeff_re_addr_next_s)+1);
					when others =>
					end case;
				end if;
			end if;
		end if;
	end process;

	read_process : process( S_AXI_ACLK ) is
	begin
		if (rising_edge (S_AXI_ACLK)) then
			if (reset = '1') then
				readdata_s <= (others => '0');
				read_ack_o <= '0';
				read_addr_im_s <= (others => '0');
				data_addr_s <= (others => '0');
			else
				data_addr_s <= data_addr_s;
				read_addr_im_s <= read_addr_im_s;
				read_ack_o <= '0';
		   		readdata_s <= readdata_s;
				if (read_en_i = '1') then
					read_ack_o <= '1';
			  		case addr_i is --read_addr is
		  			when REG_ID =>
						readdata_s <= x"ff55AA22";
						read_addr_im_s <= (others => '0');
						read_addr_re_s <= (others => '0');
						data_addr_s <= (others => '0');
					when REG_IM_COEFF =>
						readdata_s <= (C_S_AXI_DATA_WIDTH-1 downto COEFF_SIZE => 
							read_coeff_im_i(COEFF_SIZE-1))&read_coeff_im_i;
						read_addr_im_s <=
							std_logic_vector(unsigned(read_addr_im_s) + 1);
					when REG_RE_COEFF =>
						readdata_s <= (C_S_AXI_DATA_WIDTH-1 downto COEFF_SIZE => 
							read_coeff_re_i(COEFF_SIZE-1))&read_coeff_re_i;
						read_addr_re_s <=
							std_logic_vector(unsigned(read_addr_re_s) + 1);
					when REG_DATA =>
						readdata_s <= data_i;
						data_addr_s <= std_logic_vector(unsigned(data_addr_s) + 1);
					when others =>
						readdata_s <= x"55AA55AA";
					end case;
				end if;
			end if;
	  	end if;
	end process read_process;
end arch_imp;
