library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

Entity wb_cvb is 
    generic(
		ACCUM_SIZE : natural := 8;
		ADDR_SIZE : natural := 16;
		DFLT_START_OFFSET : natural := 500;
		DFLT_STOP_OFFSET : natural := 1024;
		DFLT_LIMIT : natural := 100000;
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
		start_mean_offset_o : out std_logic_vector(ADDR_SIZE-1 downto 0);
		max_allowed_val_o : out std_logic_vector(ACCUM_SIZE-1 downto 0);
		cpt_max_o : out std_logic_vector(ADDR_SIZE-1 downto 0)
    );
end entity wb_cvb;


-----------------------------------------------------------------------
Architecture wb_cvb_1 of wb_cvb is
-----------------------------------------------------------------------
	constant REG_ID     : std_logic_vector := "00";
	constant REG_OFFSET : std_logic_vector :="01";
	constant REG_VAL_MAX : std_logic_vector :="10";
	constant REG_CPT_MAX : std_logic_vector :="11";
	signal readdata_s : std_logic_vector(wb_size-1 downto 0);

	signal start_mean_offset_s : std_logic_vector(ADDR_SIZE-1 downto 0);
	signal max_allowed_val_s : std_logic_vector(ACCUM_SIZE-1 downto 0);
	signal cpt_max_s : std_logic_vector(ADDR_SIZE-1 downto 0);
begin
	wbs_readdata <= readdata_s;

	start_mean_offset_o <= start_mean_offset_s;
	max_allowed_val_o <= max_allowed_val_s;
	cpt_max_o <= cpt_max_s;

	-- manage register
	write_bloc : process(clk, reset)
	begin
		 if reset = '1' then 
			 start_mean_offset_s <= std_logic_vector(to_unsigned(
			 						DFLT_START_OFFSET, ADDR_SIZE));
			 max_allowed_val_s <= std_logic_vector(to_unsigned(
			 						DFLT_LIMIT, ACCUM_SIZE));
			 cpt_max_s <= std_logic_vector(to_unsigned(
			 						DFLT_STOP_OFFSET, ADDR_SIZE));
		 elsif rising_edge(clk) then
		 	start_mean_offset_s <= start_mean_offset_s;
			max_allowed_val_s <= max_allowed_val_s;
			cpt_max_s <= cpt_max_s;
			if (wbs_write = '1' ) then
				case wbs_add is
				when REG_OFFSET =>
					start_mean_offset_s <= wbs_writedata(ADDR_SIZE-1 downto 0);
				when REG_VAL_MAX =>
					max_allowed_val_s <= wbs_writedata(ACCUM_SIZE-1 downto 0);
				when REG_CPT_MAX =>
					cpt_max_s <= wbs_writedata(ADDR_SIZE-1 downto 0);
				when others =>
				end case;
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
				case wbs_add is
				when REG_ID =>
					readdata_s <= std_logic_vector(to_unsigned(id,wb_size));
				when REG_OFFSET =>
					readdata_s <= (wb_size-1 downto ADDR_SIZE => '0')&
						start_mean_offset_s;
				when REG_VAL_MAX =>
					readdata_s <= (wb_size-1 downto ACCUM_SIZE => '0')&
						max_allowed_val_s;
				when REG_CPT_MAX =>
					readdata_s <= (wb_size-1 downto ADDR_SIZE => '0')&cpt_max_s;
				end case;
			end if;
		end if;
	end process read_bloc;

end architecture wb_cvb_1;

