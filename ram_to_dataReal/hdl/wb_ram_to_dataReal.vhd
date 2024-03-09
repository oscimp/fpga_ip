library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

Entity wb_ram_to_dataReal is 
    generic(
		COEFF_ADDR_SIZE : natural := 8;
		COEFF_SIZE : natural := 16;
        id        : natural := 1;
        wb_size   : natural := 16 -- Data port size for wishbone
    );
    port 
    (
		-- Syscon signals
		reset     : in std_logic ;
		clk       : in std_logic ;
		-- Wishbone signals
		wbs_add       : in std_logic_vector(1 downto 0);
		wbs_write     : in std_logic ;
		wbs_writedata : in std_logic_vector( wb_size-1 downto 0);
		wbs_read     : in std_logic ;
		wbs_readdata  : out std_logic_vector( wb_size-1 downto 0);
		coeff_en_o : out std_logic;
		coeff_addr_o : out std_logic_vector(COEFF_ADDR_SIZE-1 downto 0);
		coeff_o : out std_logic_vector(COEFF_SIZE-1 downto 0)
    );
end entity wb_ram_to_dataReal;


-----------------------------------------------------------------------
Architecture wb_ram_to_dataReal_1 of wb_ram_to_dataReal is
-----------------------------------------------------------------------
	constant REG_ID     : std_logic_vector := "00";
	constant REG_COEFF : std_logic_vector :="01";
	constant REG_RESET_COEFF : std_logic_vector :="10";
	signal readdata_s : std_logic_vector(wb_size-1 downto 0);

	signal coeff_en_s : std_logic;
	signal coeff_s : std_logic_vector(COEFF_SIZE-1 downto 0);
	signal coeff_addr_s : std_logic_vector(COEFF_ADDR_SIZE-1 downto 0);
	signal coeff_next_addr_s : std_logic_vector(COEFF_ADDR_SIZE-1 downto 0);
begin
	wbs_readdata <= readdata_s;
	coeff_o <= coeff_s;
	coeff_addr_o <= coeff_addr_s;

	-- manage register
	write_bloc : process(clk, reset)
	begin
		 if rising_edge(clk) then
			 if reset = '1' then 
				 coeff_s <= (others => '0');
				 coeff_addr_s <= (others => '0');
				 coeff_next_addr_s <= (others => '0');
				 coeff_en_o <= '0';
			else
		 		coeff_s <= coeff_s;
				coeff_addr_s <= coeff_addr_s;
				coeff_next_addr_s <= coeff_next_addr_s;
				coeff_en_o <= '0';
				if (wbs_write = '1' ) then
					case wbs_add is
					when REG_COEFF =>
						coeff_s <= wbs_writedata(COEFF_SIZE-1 downto 0);
						coeff_en_o <= '1';
						coeff_addr_s <= coeff_next_addr_s;
						coeff_next_addr_s <= std_logic_vector(
							unsigned(coeff_next_addr_s) + 1);
					when REG_RESET_COEFF =>
			 			coeff_addr_s <= (others => '0');
			 			coeff_next_addr_s <= (others => '0');
					when others =>
					end case;
				end if;
			  end if;
		 end if;
	end process write_bloc;

	read_bloc : process(clk, reset)
	begin
		if rising_edge(clk) then
			if reset = '1' then
				readdata_s <= (others => '0');
			else
				readdata_s <= readdata_s;
				if (wbs_read = '1') then
					if (wbs_add = REG_ID) then
						readdata_s <= std_logic_vector(to_unsigned(id,wb_size));
					end if;
				end if;
			end if;
		end if;
	end process read_bloc;

end architecture wb_ram_to_dataReal_1;

