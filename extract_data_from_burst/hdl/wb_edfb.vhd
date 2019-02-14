library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

Entity wb_edfb is 
    generic(
        id        : natural := 1;
		POINT_POS : natural := 16;
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
		point_pos_en_o : out std_logic;
		point_pos_o : out std_logic_vector(15 downto 0)
    );
end entity wb_edfb;


-----------------------------------------------------------------------
Architecture wb_edfb_1 of wb_edfb is
-----------------------------------------------------------------------
	constant REG_ID     : std_logic_vector := "00";
	constant REG_POINT_POS : std_logic_vector :="01";
	signal point_pos_s : std_logic_vector(15 downto 0);
	signal readdata_s : std_logic_vector(wb_size-1 downto 0);
begin
	wbs_readdata <= readdata_s;
	point_pos_o <= point_pos_s;
	-- manage register
	write_bloc : process(clk, reset)   -- write DEPUIS l'iMx
	begin
		 if reset = '1' then 
			point_pos_s <= std_logic_vector(to_unsigned(POINT_POS, 16));
			point_pos_en_o <= '0';
		 elsif rising_edge(clk) then
			point_pos_s <= point_pos_s;
			point_pos_en_o <= '0';
			if (wbs_write = '1' ) then
				if wbs_add = REG_POINT_POS then
					point_pos_s <= wbs_writedata(15 downto 0);
					point_pos_en_o <= '1';
				end if;
			  end if;
		 end if;
	end process write_bloc;

	read_bloc : process(clk, reset)
	begin
		if reset = '1' then
			readdata_s <= (others => '0');
		elsif rising_edge(clk) then
			readdata_s <= readdata_s;
			if (wbs_read = '1') then
				if (wbs_add = REG_ID) then
					 readdata_s <= std_logic_vector(to_unsigned(id,wb_size));
				elsif wbs_add = REG_POINT_POS then
						readdata_s <= (wb_size-1 downto 16 => '0')&point_pos_s;
				end if;
			end if;
		end if;
	end process read_bloc;

end architecture wb_edfb_1;

