---------------------------------------------------------------------------
-- (c) Copyright: OscillatorIMP Digital
-- Author : Gwenhael Goavec-Merou<gwenhael.goavec-merou@trabucayre.com>
-- Creation date : 2018/06/11
---------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

entity wb_prn20b is 
	generic(
		PRESC_SIZE : natural := 16;
		DFLT_PRESC : natural := 15;
		ADDR_SIZE : natural := 4;
		wb_size   : natural := 16 -- Data port size for wishbone
	);
	port (
		-- Syscon signals
		reset	 		: in std_logic ;
		clk	   			: in std_logic ;
		-- Wishbone signals
		wbs_add	   		: in std_logic_vector(ADDR_SIZE-1 downto 0);
		wbs_writedata 	: in std_logic_vector(wb_size-1 downto 0);
		wbs_readdata  	: out std_logic_vector(wb_size-1 downto 0);
		wbs_read	  	: in std_logic;
		wbs_read_ack  	: out std_logic;
		wbs_write		: in std_logic;
		prescaler_o 	: out std_logic_vector(PRESC_SIZE-1 downto 0)
	);
end entity wb_prn20b;

-----------------------------------------------------------------------
Architecture wb_prn20b_1 of wb_prn20b is
-----------------------------------------------------------------------
	constant REG_PRESCALER 	: std_logic_vector(ADDR_SIZE-1 downto 0) := "0";
	signal readdata_s : std_logic_vector(wb_size-1 downto 0);
	signal readdata_next_s : std_logic_vector(wb_size-1 downto 0);

	signal prescaler_s : std_logic_vector(PRESC_SIZE-1 downto 0);

begin
	wbs_readdata <= readdata_s;
	prescaler_o <= prescaler_s;

	-- manage register
	write_bloc : process(clk)
	begin
		 if rising_edge(clk) then
			if reset = '1' then 
				prescaler_s <= std_logic_vector(to_unsigned(DFLT_PRESC, PRESC_SIZE));
			 else
				prescaler_s <= prescaler_s;
				if (wbs_write = '1') then
					if wbs_add = REG_PRESCALER then
						prescaler_s <= wbs_writedata(PRESC_SIZE-1 downto 0);
					end if;
				end if;
			end if;
		 end if;
	end process write_bloc;

	process(wbs_add, prescaler_s)
	begin
		if (wbs_add = REG_PRESCALER) then
			readdata_next_s <= (wb_size-1 downto PRESC_SIZE => '0')&prescaler_s;
		else
			readdata_next_s <= x"55AAAA55";
		end if;
	end process;

	read_bloc : process(clk)
	begin
		if rising_edge(clk) then
			wbs_read_ack <= '0';
			if reset = '1' then
				readdata_s <= (others => '0');
			else
		 		readdata_s <= readdata_s;
				if (wbs_read = '1') then
					wbs_read_ack <= '1';
					readdata_s <= readdata_next_s;
				end if;
			end if;
		end if;
	end process read_bloc;
end architecture wb_prn20b_1;

