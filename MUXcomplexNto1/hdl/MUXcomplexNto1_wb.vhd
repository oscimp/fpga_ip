---------------------------------------------------------------------------
-- (c) Copyright: OscillatorIMP Digital
-- Author : Gwenhael Goavec-Merou<gwenhael.goavec-merou@trabucayre.com>
-- modified : 2021/06/11
-- Creation date : 2015/04/08
---------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

Entity MUXcomplexNto1_wb is 
    generic(
        id        : natural := 1;
	--	DEFAULT_INPUT : natural := 1;
        wb_size   : natural := 16; -- Data port size for wishbone
        SEL_SIZE : integer := 2
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
		wbs_read      : in std_logic ;
		wbs_readdata  : out std_logic_vector( wb_size-1 downto 0);
		--witchInput_o : out std_logic
		outputSelect  : out std_logic_vector(SEL_SIZE - 1 downto 0) -- modified IR
		
    );
end entity MUXcomplexNto1_wb;


-----------------------------------------------------------------------
Architecture MUXcomplexNto1_wb_1 of MUXcomplexNto1_wb is
-----------------------------------------------------------------------
	constant REG_ID     : std_logic_vector(1 downto 0) := "00";
	constant REG_INPUT  : std_logic_vector(1 downto 0) :="01";
	--signal witchInput_s : std_logic;
	signal outputSelect_s : std_logic_vector(SEL_SIZE -1 downto 0); -- modified IR
	signal readdata_s : std_logic_vector(wb_size-1 downto 0);
begin
	wbs_readdata <= readdata_s;
	--witchInput_o <= witchInput_s;
	outputSelect <= outputSelect_s; -- modified IR
	-- manage register
	write_bloc : process(clk)
	begin
		if rising_edge(clk) then
			if reset = '1' then 
			    -- witchInput_s <= '0';
				outputSelect_s <= (others => '0'); -- modified IR
		 	else
		 	    -- witchInput_s <= witchInput_s;
				outputSelect_s <= outputSelect_s; -- modified IR
				if (wbs_write = '1' ) then
					if wbs_add = REG_INPUT then
						outputSelect_s <= wbs_writedata(SEL_SIZE - 1 downto 0);
					end if;
				end if;
			  end if;
		 end if;
	end process write_bloc;

	read_bloc : process(clk)
	begin
		if rising_edge(clk) then
			if reset = '1' then
				readdata_s <= (others => '0');
			else
				readdata_s <= readdata_s;
				if (wbs_read = '1') then
					if (wbs_add = REG_ID) then
						 readdata_s <= std_logic_vector(to_unsigned(id,wb_size));
					elsif wbs_add = REG_INPUT then
				--		readdata_s <= (wb_size-1 downto 1 => '0')&witchInput_s;
					    readdata_s <= (wb_size - 1 downto SEL_SIZE => '0')& outputSelect_s;
					end if;
				end if;
			end if;
		end if;
	end process read_bloc;
end architecture MUXcomplexNto1_wb_1;