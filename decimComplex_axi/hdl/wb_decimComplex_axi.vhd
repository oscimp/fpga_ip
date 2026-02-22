library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

Entity wb_decimComplex_axi is 
    generic(
		DEFAULT_DECIM 	: natural := 1;
		DATA_SIZE 		: natural := 16;
        id        		: natural := 1;
        wb_size   		: natural := 16 -- Data port size for wishbone
    );
    port (
		-- Syscon signals
		reset     : in std_logic;
		clk       : in std_logic;
		-- Wishbone signals
		wbs_add       : in std_logic_vector(2-1 downto 0);
		wbs_write     : in std_logic;
		wbs_writedata : in std_logic_vector(wb_size-1 downto 0);
		wbs_read      : in std_logic;
		wbs_readdata  : out std_logic_vector(wb_size-1 downto 0);
		decim_o      : out std_logic_vector(DATA_SIZE-1 downto 0)
    );
end entity wb_decimComplex_axi;


-----------------------------------------------------------------------
Architecture wb_decimComplex_axi_1 of wb_decimComplex_axi is
-----------------------------------------------------------------------
	constant REG_ID       : std_logic_vector := "00";
	constant REG_DECIM : std_logic_vector := "01";
	signal decim_s       : std_logic_vector(DATA_SIZE-1 downto 0);
	signal readdata_s     : std_logic_vector(wb_size-1 downto 0);
	signal off_read_s     : std_logic_vector(wb_size-1 downto 0);
begin
	wbs_readdata <= readdata_s;
	decim_o <= decim_s;

	-- manage register
	write_bloc : process(clk, reset)
	begin
		if reset = '1' then 
			decim_s <= (others => '0');
			decim_s <= std_logic_vector(to_unsigned(DEFAULT_DECIM, DATA_SIZE));
		elsif rising_edge(clk) then
			decim_s <= decim_s;
			if (wbs_write = '1' ) then
				case wbs_add is
				when REG_DECIM =>
					decim_s <= wbs_writedata(DATA_SIZE-1 downto 0);
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
				when REG_DECIM =>
					readdata_s <= (wb_size-1 downto DATA_SIZE => '0')&decim_s;
				when others =>
					readdata_s <= (others => '1');
				end case;
			end if;
		end if;
	end process read_bloc;

end architecture wb_decimComplex_axi_1;

