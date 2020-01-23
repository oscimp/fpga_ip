---------------------------------------------------------------------------
-- (c) Copyright: OscillatorIMP Digital
-- Author : Gwenhael Goavec-Merou<gwenhael.goavec-merou@trabucayre.com>
-- 2013-2018
---------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

Entity syncTrigStream_comm is 
    generic(
		DFLT_PERIOD : natural := 300000000; -- 3s@100MHz
		DFLT_DUTY   : natural := 100;       -- 1us@100MHz
		GEN_SIZE    : natural := 32;
        bus_size    : natural := 32 -- Data port size
    );
    port (
		-- Syscon signals
		reset        : in std_logic;
		clk          : in std_logic;
		-- CPU signals
		addr_i       : in std_logic_vector(1 downto 0);
		wr_en_i      : in std_logic;
		writedata_i  : in std_logic_vector(bus_size-1 downto 0);
		rd_en_i      : in std_logic;
		readdata_o   : out std_logic_vector(bus_size-1 downto 0);
		enable_o     : out std_logic;
		period_cnt_o : out std_logic_vector(GEN_SIZE-1 downto 0);
		duty_cnt_o   : out std_logic_vector(GEN_SIZE-1 downto 0)
    );
end entity syncTrigStream_comm;


-----------------------------------------------------------------------
Architecture syncTrigStream_comm_1 of syncTrigStream_comm is
-----------------------------------------------------------------------
	constant REG_PERIOD : std_logic_vector(1 downto 0) :="00";
	constant REG_DUTY   : std_logic_vector(1 downto 0) :="01";
	constant REG_ENABLE : std_logic_vector(1 downto 0) :="10";
	signal readdata_s   : std_logic_vector(bus_size-1 downto 0);
	
	signal enable_s     : std_logic;
	signal period_cnt_s : std_logic_vector(GEN_SIZE-1 downto 0);
	signal duty_cnt_s   : std_logic_vector(GEN_SIZE-1 downto 0);
begin
	readdata_o <= readdata_s;
	period_cnt_o <= period_cnt_s;
	duty_cnt_o <= duty_cnt_s;
	enable_o <= enable_s;
	-- manage register
	write_bloc : process(clk) begin
		 if rising_edge(clk) then
		 	if reset = '1' then 
				period_cnt_s <= std_logic_vector(to_unsigned(DFLT_PERIOD, GEN_SIZE));
				duty_cnt_s <= std_logic_vector(to_unsigned(DFLT_DUTY, GEN_SIZE));
				enable_s <= '0';
		 	else
				period_cnt_s <= period_cnt_s;
				duty_cnt_s <= duty_cnt_s;
				enable_s <= enable_s;
				if (wr_en_i = '1' ) then
					case addr_i is
					when REG_PERIOD =>
						period_cnt_s <= writedata_i(GEN_SIZE-1 downto 0);
					when REG_DUTY =>
						duty_cnt_s <= writedata_i(GEN_SIZE-1 downto 0);
					when REG_ENABLE =>
						enable_s <= writedata_i(0);
					when others =>
					end case;
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
			if (rd_en_i = '1') then
				case addr_i is
				when REG_PERIOD =>
					readdata_s <= period_cnt_s;
				when REG_DUTY =>
					readdata_s <= duty_cnt_s;
				when REG_ENABLE =>
					readdata_s <= (bus_size-1 downto 1 => '0') & enable_s;
				when others =>
					readdata_s <= (others => '1');
				end case;
			end if;
		end if;
	end process read_bloc;

end architecture syncTrigStream_comm_1;

