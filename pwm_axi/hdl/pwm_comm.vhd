library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

Entity pwm_comm is 
generic(
    id : natural := 1;
	COUNTER_SIZE : natural := 32;
	AXI_DATA_WIDTH : integer := 32
);
port (
	-- Syscon signals
	reset  : in std_logic ;
	clk    : in std_logic ;
	-- axi signals
	addr_i    	: in std_logic_vector(2 downto 0);
	write_en_i  : in std_logic;
	writedata   : in std_logic_vector(AXI_DATA_WIDTH-1 downto 0);
	read_en_i	: in std_logic;
	read_ack_o	: out std_logic;
	readdata    : out std_logic_vector(AXI_DATA_WIDTH-1 downto 0);
	-- out signals
	enable_o 	: out std_logic;
	invert_o 	: out std_logic;
	prescaler_o	: out std_logic_vector(COUNTER_SIZE-1 downto 0);
	duty_o		: out std_logic_vector(COUNTER_SIZE-1 downto 0);
	period_o	: out std_logic_vector(COUNTER_SIZE-1 downto 0)
);
end entity pwm_comm;


-----------------------------------------------------------------------
Architecture pwm_comm_1 of pwm_comm is
-----------------------------------------------------------------------
	constant REG_ID		: std_logic_vector(2 downto 0) := "000";
	constant REG_CTRL	: std_logic_vector(2 downto 0) := "001";
	constant REG_DUTY	: std_logic_vector(2 downto 0) := "010";
	constant REG_PERIOD	: std_logic_vector(2 downto 0) := "011";
	constant REG_PRESCALER	: std_logic_vector(2 downto 0) := "100";

	signal enable_s, invert_s : std_logic;
	signal duty_s      : std_logic_vector(COUNTER_SIZE-1 downto 0);
	signal period_s    : std_logic_vector(COUNTER_SIZE-1 downto 0);
	signal prescaler_s : std_logic_vector(COUNTER_SIZE-1 downto 0);
	signal readdata_s  : std_logic_vector(AXI_DATA_WIDTH-1 downto 0);
	signal writedata_s : std_logic_vector(COUNTER_SIZE-1 downto 0);
begin
	duty_o <= duty_s;
	period_o <= period_s;
	prescaler_o <= prescaler_s;
	enable_o <= enable_s;
	invert_o <= invert_s;

	readdata <= readdata_s;
	writedata_s <= writedata(COUNTER_SIZE-1 downto 0);

	-- manage register
	write_bloc : process(clk)
	begin
		if rising_edge(clk) then
    		if reset = '1' then 
				enable_s    <= '0';
				invert_s    <= '0';
				prescaler_s	<= (others => '0');
				period_s	<= (others => '0');
				duty_s		<= (others => '0');
    		elsif (write_en_i = '1' ) then
				case addr_i is
				when REG_CTRL =>
					enable_s <= writedata(0);
					invert_s <= writedata_s(1);
				when REG_PERIOD =>
					period_s <= writedata_s;
				when REG_DUTY =>
					duty_s <= writedata_s;
				when REG_ID =>
					prescaler_s <= writedata_s;
				when REG_PRESCALER =>
					prescaler_s <= writedata_s;
				when others =>
				end case;
    		end if;
		end if;
	end process write_bloc;

read_bloc : process(clk, reset)
begin
    if reset = '1' then
        readdata_s <= (others => '0');
		read_ack_o <= '0';
	elsif rising_edge(clk) then
		readdata_s <= readdata_s;
		read_ack_o <= '0';
		if (read_en_i = '1') then
			read_ack_o <= '1';
			case addr_i is
			when REG_ID =>
				readdata_s <= std_logic_vector(to_unsigned(id, AXI_DATA_WIDTH));
			when REG_CTRL =>
				readdata_s <= (AXI_DATA_WIDTH-1 downto 2 => '0')&invert_s &
					enable_s;
			when REG_PERIOD =>
				readdata_s <= std_logic_vector(resize(unsigned(period_s), AXI_DATA_WIDTH));
			when REG_DUTY =>
				readdata_s <= std_logic_vector(resize(unsigned(duty_s), AXI_DATA_WIDTH));
			when REG_PRESCALER =>
				readdata_s <= std_logic_vector(resize(unsigned(prescaler_s), AXI_DATA_WIDTH));
			when others =>
				readdata_s <= (others => '1');
			end case;
        end if;
    end if;
end process read_bloc;

end architecture pwm_comm_1;

