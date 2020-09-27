-- source https://opencores.org/projects/system09
-- http://volkerschatz.de/hardware/vhdocl-example/sources/spi-master.html

library ieee; 
  use ieee.std_logic_1164.all; 
  use ieee.std_logic_unsigned.all; 
 
entity spi_master is 
  port ( 
    --+ CPU Interface Signals 
    clk                : in  std_logic; 
    reset              : in  std_logic; 
    start_en	       : in  std_logic:= '0';
    data_in            : in  std_logic_vector(20 downto 0); --(20 downto 0) = datasize -1 downto 0 
    --+ SPI Interface Signals  
    spi_mosi           : out std_logic; 
    spi_clk            : out std_logic; 
    spi_cs_n           : out std_logic 
    ); 
end; 
 
architecture rtl of spi_master is 
 
  --* State type of the SPI transfer state machine 
  type   state_type is (s_idle, s_running); 
  signal state           : state_type; 
  -- Shift register 
  signal shift_reg       : std_logic_vector(23 downto 0); --(23 downto 0) = datasize +2 downto 0
  -- Buffer to hold data to be sent 
  signal spi_data_buf    : std_logic_vector(23 downto 0); --(23 downto 0) = datasize +2 downto 0
  -- Start transmission flag 
  signal start, start_s          : std_logic := '0'; 
  -- Number of bits transfered 
  signal count           : std_logic_vector(4 downto 0); 
  -- Buffered SPI clock 
  signal spi_clk_buf     : std_logic; 
  -- Buffered SPI clock output 
  signal spi_clk_out     : std_logic; 
  -- Previous SPI clock state 
  signal prev_spi_clk    : std_logic; 
  -- Number of clk cycles-1 in this SPI clock period 
  signal spi_clk_count   : std_logic_vector(23 downto 0);
  -- SPI clock divisor 
  signal spi_clk_divide  : std_logic_vector(1 downto 0); 
  -- SPI transfer length 
  signal transfer_length : std_logic_vector(1 downto 0); 
  -- Flag to indicate that the SPI slave should be deselected after the current 
  -- transfer 
  signal deselect        : std_logic; 
  signal spi_cs          : std_logic; 
  constant dn: positive := 50;
  signal delay: std_logic_vector(dn-1 downto 0) := (others => '0');
begin 
 
  --* Read CPU bus into internal registers 
  cpu_write : process(clk, reset) 
  begin 
  spi_clk_divide  <= "11"; -- divise la clock 
    if reset = '1' then 
      deselect        <= '1'; 
      spi_data_buf    <= (others => '0'); 
    elsif falling_edge(clk) then 
      if start_en = '1' then
        start          <= '1';
        spi_data_buf   <= "000" & data_in;
        deselect       <= '0';
	  else
	    start          <= '0';
	    deselect       <= '1';
	    spi_data_buf   <= (others => '0');
      end if;
    end if; 
  end process;

spi_cs_n <= spi_cs;

  
p_rising_edge_detector : process(clk)
begin
  if falling_edge(clk) then
    delay <= delay(dn-2 downto 0) & start;
  end if;
end process p_rising_edge_detector;
start_s            <= not delay(dn-1) and start;

		
  --* SPI transfer state machine 
  spi_proc : process(clk, reset) 
  begin 
    if reset = '1' then 
      count        <= (others => '0'); 
      shift_reg    <= (others => '0'); 
      prev_spi_clk <= '0'; 
      spi_clk_out  <= '1'; 
      spi_cs       <= '1';
    elsif falling_edge(clk) then 
      prev_spi_clk <= spi_clk_buf; 
      case state is 
        when s_idle => 
          if start_s = '1' then 
            count     <= (others => '0'); 
            shift_reg <= spi_data_buf; 
            spi_cs    <= '0'; 
            state     <= s_running; 
          elsif deselect = '1' then 
            spi_cs <= '1';
          end if;
        when s_running => 
          if prev_spi_clk = '1' and spi_clk_buf = '0' then 
            spi_clk_out <= '1';
            count       <= count + "00001";
            shift_reg   <= shift_reg(22 downto 0) & '0'; -- (22 downto 0) = (datasize+1 downto 0)
            if (count = "11000") then -- 11000 = 24 = (datasize+3 downto 0)
              if deselect = '1' then 
                spi_cs <= '1'; 
              end if; 
              state <= s_idle; 
            end if; 
          elsif prev_spi_clk = '0' and spi_clk_buf = '1' then 
            spi_clk_out <= '0';
          end if; 
        when others => 
          null; 
      end case; 
    end if; 
  end process; 
 
  --* Generate SPI clock 
  spi_clock_gen : process(clk, reset) 
  begin 
    if reset = '1' then 
      spi_clk_count <= (others => '0'); 
      spi_clk_buf   <= '0'; 
    elsif falling_edge(clk) then     
      if state = s_running then 
        if ((spi_clk_divide = "00") -- 125MHz
            or (spi_clk_divide = "11" and spi_clk_count = "000000000000000011111101") -- 1MHz
            or (spi_clk_divide = "01" and spi_clk_count = "111111111111111111111111")) then -- 15Hz
          spi_clk_buf <= not spi_clk_buf; 
          spi_clk_count <= (others => '0'); 
        else 
          spi_clk_count <= spi_clk_count + "000000000000000000000001"; 
        end if; 
      else 
        spi_clk_buf <= '0'; 
      end if; 
    end if;
  end process; 

  spi_mosi <= shift_reg(23); -- 23 = datasize + 2  
  
  spi_clk  <= not spi_clk_out; 
 
end rtl;

