library ieee;
use ieee.std_logic_1164.all;
--use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity clock_prescaler is
generic( 
		DIVISOR : natural range 0 to 255 := 122
	);
port (
     cout   :out std_logic_vector (7 downto 0); -- Output of the counter
 --    data   :in  std_logic_vector (7 downto 0); -- Parallel load for the counter
 --    load   :in  std_logic;                     -- Parallel load enable
 --    enable :in  std_logic;                     -- Enable counting
     clk    :in  std_logic;                     -- Input clock
     rst  :in  std_logic;                      -- Input reset
     en_out :out std_logic
   );
 end entity;
 
 architecture rtl of clock_prescaler is
	signal count, maximum : std_logic_vector (7 downto 0);
 	signal en_s : std_logic;
    
 begin
 	maximum <= std_logic_vector(to_unsigned(DIVISOR - 1,8));
     process (clk, rst) begin
         if (rst = '1') then
             count <= (others=> '0');
         elsif (rising_edge(clk)) then
             if (unsigned(count) = unsigned(maximum)) then
                 count <= (others => '0');
             else
                 count <= std_logic_vector(unsigned(count) + 1);
             end if;
         end if;
     end process;
     process (clk, rst)
     begin
     	if (rst = '1') then
        	en_s <= '0';
        elsif (rising_edge(clk)) then
        	if (unsigned(count) = 0) then
            	en_s <= '1';
            else
            	en_s <= '0';
            end if;
    --    else
       -- 	en_s <= en_s;
       end if;
       end process;
	 en_out <= en_s;  
     cout <= count;
 end architecture;
