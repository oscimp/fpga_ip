library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity delayTempoReal_axi_comm is
	generic (
		DEFAULT_DELAY : natural := 0;
		DELAY_ADDR_SZ : natural := 10;
		AXI_ADDR_WIDTH : integer := 1;
		C_S_AXI_DATA_WIDTH	: integer	:= 32
	);
	port (
		clk_i		: in std_logic;
		reset		: in std_logic;
		addr_i	  	: in std_logic_vector(AXI_ADDR_WIDTH-1 downto 0);
		write_en_i	: in std_logic;
		writedata	: in std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		read_en_i 	: in std_logic;
		read_ack_o 	: out std_logic;
		readdata	: out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		delay_o		: out std_logic_vector(DELAY_ADDR_SZ-1 downto 0)
	);
end delayTempoReal_axi_comm;

architecture arch_imp of delayTempoReal_axi_comm is
	constant REG_DELAY : std_logic_vector(0 downto 0) := "0";
	signal readdata_s	: std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);

	signal delay_s : std_logic_vector(DELAY_ADDR_SZ-1 downto 0);
begin
	delay_o <= delay_s;
	readdata <= readdata_s;

	write_process : process (clk_i)
	begin
		if rising_edge(clk_i) then 
			if  reset = '1' then
				delay_s <= std_logic_vector(
						to_unsigned(DEFAULT_DELAY, DELAY_ADDR_SZ));
			else
				delay_s <= delay_s;
				if (write_en_i = '1') then
					if (addr_i = "0") then
						delay_s <= writedata(DELAY_ADDR_SZ-1 downto 0);
					end if;
				end if;
			end if;
		end if;
	end process;

	read_process : process(clk_i) is
	begin
		if rising_edge(clk_i) then
			if reset = '1' then
				readdata_s <= (others => '0');
				read_ack_o <= '0';
			else
		   		readdata_s <= readdata_s;
				read_ack_o <= '0';
				if read_en_i = '1' then
					read_ack_o <= '1';
			  		if addr_i = "0" then
						readdata_s <= 
								(C_S_AXI_DATA_WIDTH-1 downto DELAY_ADDR_SZ => '0') & delay_s;
					else 
						readdata_s <= x"55AA55AA";
					end if;
				end if;
			end if;
	  	end if;
	end process read_process;
end arch_imp;
