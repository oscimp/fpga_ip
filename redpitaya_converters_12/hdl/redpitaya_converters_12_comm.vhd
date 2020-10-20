library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

Entity redpitaya_converters_12_comm is 
generic(
    id : natural := 1;
	CONF_SIZE : integer := 14; 
	BUS_SIZE : natural := 32;
	INTERNAL_ADDR_WIDTH : integer := 3
);
port (
	-- Syscon signals
	reset  : in std_logic ;
	clk    : in std_logic ;
	-- axi signals
	addr_i		 : in std_logic_vector(2 downto 0);
	write_en_i	 : in std_logic;
	writedata	 : in std_logic_vector(BUS_SIZE-1 downto 0);
	read_en_i	 : in std_logic;
	readdata	 : out std_logic_vector(BUS_SIZE-1 downto 0);
	-- out signals
	conf_o       : out std_logic_vector(CONF_SIZE-1 downto 0);
	conf_sel_o   : out std_logic;
	conf_en_o    : out std_logic;
	pll_cfg_en_o : out std_logic;
	-- in signal
	pll_ok_i     : in std_logic
);
end entity redpitaya_converters_12_comm;

-----------------------------------------------------------------------
Architecture redpitaya_converters_12_comm_1 of redpitaya_converters_12_comm is
-----------------------------------------------------------------------

	constant REG_CONF		    : std_logic_vector(2 downto 0) := "000";
	constant REG_ADC_DAC_SEL	: std_logic_vector(2 downto 0) := "001";
	constant REG_CONF_EN	    : std_logic_vector(2 downto 0) := "010";
	constant REG_PLL_EN         : std_logic_vector(2 downto 0) := "011";
	constant REG_PLL_OK         : std_logic_vector(2 downto 0) := "100";

	signal conf_s		    : std_logic_vector(CONF_SIZE-1 downto 0);
    signal conf_sel_s       : std_logic;
    signal conf_en_s        : std_logic;
    signal pll_cfg_en_s     : std_logic;
    signal pll_ok_s         : std_logic;

	signal readdata_s	: std_logic_vector(BUS_SIZE-1 downto 0);
	
begin
	    conf_o       <= conf_s;
    	conf_sel_o   <= conf_sel_s;
    	conf_en_o    <= conf_en_s;
        pll_cfg_en_o <= pll_cfg_en_s;
        
	readdata <= readdata_s;
    
    
	-- manage register
	write_bloc : process(clk,reset)
	begin
		if reset = '1' then 
			conf_sel_s   <= '0';
			conf_en_s    <= '0';
			conf_s	     <= (others => '0');	
			pll_cfg_en_s <= '0';
		elsif rising_edge(clk) then
		    conf_en_s    <= conf_en_s;
			conf_sel_s   <= conf_sel_s; 
			conf_s	     <= conf_s;
			pll_cfg_en_s <= pll_cfg_en_s;
			if (write_en_i = '1' ) then
				case addr_i is
				when REG_CONF =>
					conf_s <= writedata(CONF_SIZE-1 downto 0);
				when REG_ADC_DAC_SEL =>
					conf_sel_s <= writedata(0);
			    when REG_CONF_EN =>
					    conf_en_s <= writedata(0);
		        when REG_PLL_EN =>
					    pll_cfg_en_s <= writedata(0);
				when others =>
				end case;
			  end if;
		 end if;
	end process write_bloc;

	read_bloc : process(clk, reset)
	begin
		if reset = '1' then
			readdata_s <= (others => '0');
			pll_ok_s   <= '0';
		elsif rising_edge(clk) then
			readdata_s <= readdata_s;
			pll_ok_s   <= pll_ok_i;
			if (read_en_i = '1') then
				case addr_i is
				when REG_CONF =>
					readdata_s <= (BUS_SIZE-1 downto CONF_SIZE => conf_s(CONF_SIZE-1)) & conf_s;
				when REG_ADC_DAC_SEL =>
					readdata_s <= (BUS_SIZE-1 downto 1 => '0') & conf_sel_s;
				when REG_CONF_EN =>
					readdata_s <= (BUS_SIZE-1 downto 1 => '0') & conf_en_s;
			    when REG_PLL_EN =>
					readdata_s <= (BUS_SIZE-1 downto 1 => '0') & pll_cfg_en_s;
				when REG_PLL_OK =>
					readdata_s <= (BUS_SIZE-1 downto 1 => '0') & pll_ok_s;
				when others =>
					readdata_s <= (others => '1');
				end case;
			end if;
		end if;
	end process read_bloc;

end architecture redpitaya_converters_12_comm_1;

