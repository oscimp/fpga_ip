library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
USE std.textio.ALL;
use IEEE.math_real.all;

entity top_decimComplex_axi_tb is
end entity top_decimComplex_axi_tb;

architecture RTL of top_decimComplex_axi_tb is
	signal reset : std_logic;
	CONSTANT HALF_PERIODE : time := 5.0 ns;  -- Half clock period
	signal clk : std_logic;

	constant DATA_SIZE : natural := 16;
	signal data_en_s, data_en_o : std_logic;
	signal data_i_s, data_q_s : std_logic_vector(DATA_SIZE-1 downto 0);
	signal data_i_o, data_q_o : std_logic_vector(DATA_SIZE-1 downto 0);

	constant MAX_DECIM : natural := 256;
	constant DECIM_SIZE : natural := natural(ceil(log2(real(MAX_DECIM))));
	signal decim_s : std_logic_vector(DECIM_SIZE-1 downto 0);
begin

	decim_inst: Entity work.decimComplex_axi_logic
	generic map (DECIM_SIZE => DECIM_SIZE,
		DATA_SIZE => DATA_SIZE)
	port map (data_rst_i => reset, data_clk_i => clk,
		decim_i => decim_s,
		data_i_i => data_i_s, data_q_i => data_q_s,
		data_en_i => data_en_s,
		data_i_o => data_i_o, data_q_o => data_q_o,
		data_en_o => data_en_o);

	data_propagation : process(clk, reset)
	begin
		if (reset = '1') then
			data_i_s <= (others => '0');
			data_q_s <= (others => '0');
			data_en_s <= '0';
		elsif rising_edge(clk) then
			data_i_s <= std_logic_vector(unsigned(data_i_s) +1);
			data_q_s <= std_logic_vector(unsigned(data_q_s) +1);
			data_en_s <= '1';
		end if;
	end process; 

	stimulis : process
	begin
	decim_s <= x"03";
	reset <= '0';
	wait until rising_edge(clk);
	reset <= '1';
	wait until rising_edge(clk);
	wait until rising_edge(clk);
	wait until rising_edge(clk);
	reset <= '0';
	wait for 500 ns;
	decim_s <= x"06";
	wait for 200 ns;
	wait until rising_edge(clk);
	wait until rising_edge(clk);
	wait for 200 ns;
	decim_s <= x"01";
	wait for 200 ns;
	decim_s <= x"0a";
	wait for 200 ns;
	decim_s <= x"0a";
	wait for 200 ns;
	decim_s <= x"01";
	wait for 200 ns;
	assert false report "End of test" severity error;
	end process stimulis;
	
	clockp : process
	begin
		clk <= '1';
		wait for HALF_PERIODE;
		clk <= '0';
		wait for HALF_PERIODE;
	end process clockp;
	
end architecture RTL;
