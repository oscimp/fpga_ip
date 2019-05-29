library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
use IEEE.math_real.all;

entity top_slv_to_sl_axi_tb is
end entity top_slv_to_sl_axi_tb;

architecture RTL of top_slv_to_sl_axi_tb is
	CONSTANT HALF_PERIOD : time := 5.0 ns;  -- Half clock period
	signal clk, reset : std_logic;
	
	constant SLV_SIZE : natural := 32;
	constant OFFSET_ADDR_SZ : natural := natural(ceil(log2(real(SLV_SIZE))));
    signal offset_s : std_logic_vector(OFFSET_ADDR_SZ-1 downto 0);
    signal sl_s : std_logic;
	signal slv_s : std_logic_vector(SLV_SIZE-1 downto 0);

begin

    sl_s <= slv_s(to_integer(unsigned(offset_s)));

	
	stimulis : process
	begin
	slv_s <= (others => '0');
	offset_s <= (others => '0');
	reset <= '1';
	wait until rising_edge(clk);
	reset <= '1';
	wait until rising_edge(clk);
	wait until rising_edge(clk);
	wait until rising_edge(clk);
	reset <= '0';
	-- offset 0
	wait until rising_edge(clk);
	slv_s <= (SLV_SIZE-1 downto 1 => '0')&'1';
	wait until rising_edge(clk);
	assert sl_s = '1' report "test1 ok" severity error;
	-- offset 1
	offset_s <= "00001";
	wait until rising_edge(clk);
	assert sl_s = '0' report "test1 ok" severity error;
	slv_s <= slv_s(SLV_SIZE-2 downto 0)&slv_s(SLV_SIZE-1);
	wait until rising_edge(clk);
	assert sl_s = '1' report "test2 ok" severity error;
	-- offset 2
	offset_s <= "00010";
	wait until rising_edge(clk);
	assert sl_s = '0' report "test2 ok" severity error;
	slv_s <= slv_s(SLV_SIZE-2 downto 0)&slv_s(SLV_SIZE-1);
	wait until rising_edge(clk);
	assert sl_s = '1' report "test2 ok" severity error;
	-- offset 3
	offset_s <= "00011";
	wait until rising_edge(clk);
	assert sl_s = '0' report "test2 ok" severity error;
	slv_s <= slv_s(SLV_SIZE-2 downto 0)&slv_s(SLV_SIZE-1);
	wait until rising_edge(clk);
	assert sl_s = '1' report "test2 ok" severity error;




	wait for 10 ns;
	wait for 10 ns;
	wait for 10 ns;
	wait until rising_edge(clk);
	wait until rising_edge(clk);
	wait until rising_edge(clk);
	wait for 10 us;
	wait for 10 us;
	wait for 10 us;
	wait for 10 us;
	wait until rising_edge(clk);
	wait until rising_edge(clk);
	--wait for 1 ms;
	assert false report "End of test" severity error;
	end process stimulis;

	clockp : process
	begin
		clk <= '1';
		wait for HALF_PERIOD;
		clk <= '0';
		wait for HALF_PERIOD;
	end process clockp;

end architecture RTL;
