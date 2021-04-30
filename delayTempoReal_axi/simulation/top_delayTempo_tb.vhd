library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
use IEEE.math_real.all;

entity top_delayTempo_tb is
end entity top_delayTempo_tb;

architecture RTL of top_delayTempo_tb is
	constant DATA_SIZE : natural := 14;

	signal reset : std_logic;
	CONSTANT HALF_PERIODE : time := 5.0 ns;  -- Half clock period
	signal clk : std_logic;

	-- new
	signal data_in_s, data_out_s : std_logic_vector(DATA_SIZE-1 downto 0);
	signal data_in_en_s, data_out_en_s : std_logic;
	-- output result from fir
	constant SL_MAX : natural := 1;
	signal start_prod : std_logic;
	constant MAX_CNT : natural := 6;
	signal cpt_s : natural range 0 to MAX_CNT-1;


	constant MAX_NB_DELAY : natural := 10;
	constant DELAY_ADDR_SZ : natural := natural(ceil(log2(real(MAX_NB_DELAY))));
    signal delay_s : std_logic_vector(DELAY_ADDR_SZ-1 downto 0);

begin

	delay_inst : Entity work.delayTempoReal_axi_logic
	generic map (
		DELAY_SIZE => DELAY_ADDR_SZ,
		DATA_SIZE => DATA_SIZE
	)
	port map (
		rst_i		=> reset,
		clk_i		=> clk,
		delay_i		=> delay_s,
		-- input data
		data_i		=> data_in_s,
		data_en_i	=> data_in_en_s,
		data_eof_i	=> '0',
		-- for the next component
		data_o		=> data_out_s,		
		data_en_o	=> data_out_en_s,
		data_eof_o	=> open
	);

	-- generate data flow
	data_propagation : process(clk, reset)
	begin
		if (reset = '1') then
			data_in_s <= (DATA_SIZE-1 downto 0 => '0');
			data_in_en_s <= '0';
			cpt_s <= 0;
		elsif rising_edge(clk) then
			cpt_s <= cpt_s;
			data_in_en_s <= '0';
			data_in_s <= data_in_s;
			if start_prod = '1' then
				if cpt_s < MAX_CNT-1 then
					cpt_s <= cpt_s + 1;
				else
					cpt_s <= 0;

					data_in_s <= std_logic_vector(to_unsigned(cpt_s, DATA_SIZE)); 
					data_in_s <= std_logic_vector(unsigned(data_in_s) +1);
					data_in_en_s <= '1';
				end if;
			end if;
		end if;
	end process; 

    stimulis : process
    begin
	delay_s <= x"3";
	start_prod <= '0';
	reset <= '0';
	wait until rising_edge(clk);
	reset <= '1';
	wait until rising_edge(clk);
	wait until rising_edge(clk);
	wait until rising_edge(clk);
	reset <= '0';
    wait for 10 ns;
	wait until rising_edge(clk);
	wait until rising_edge(clk);
	start_prod <= '1';
    wait for 10 us;
	delay_s <= x"0";
    wait for 100 ns;
	wait until rising_edge(clk);
	delay_s <= x"1";
	wait until rising_edge(clk);
    wait for 10 us;
    wait for 10 us;
    wait for 10 us;
    wait for 10 us;
    wait for 10 us;
    wait for 10 us;
    wait for 10 us;
    wait for 10 us;
	wait for 1 ms;
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
