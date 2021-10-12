-----------------------------------------------------------------------
-- (c) Copyright: OscillatorIMP Digital
-- Author : Ivan Ryger, ivan.ryger@femto-st.fr
-- Creation date : 2021/09/14
-----------------------------------------------------------------------
--testbench run on Cadence Xcelium 20.09 compile options: -v200x run options: -access +rw
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
--use std.textio.all;

entity iir_lpf_real_tb is
	end iir_lpf_real_tb;

architecture tb of iir_lpf_real_tb is
	component iir_lpf_real is 
	generic(
		DATA_WIDTH : natural := 16;
		FILTER_COEFF_TWOS_POWER : natural := 10 
		);
	port(
		data_i 		: in std_logic_vector(DATA_WIDTH-1 downto 0);
		data_en_i 	: in std_logic;
		data_clk_i	: in std_logic;
		data_rst_i	: in std_logic;	
		data_o 		: out std_logic_vector(DATA_WIDTH-1 downto 0);
		data_en_o	: out std_logic;
		data_clk_o	: out std_logic;
		data_rst_o	: out std_logic
		);
	end component iir_lpf_real;
	
	constant T : time := 8 ns;
	constant F : real := 1000.0*(125000.0**(-1));
	constant DATA_WIDTH : natural := 16;
    constant FILTER_COEFF_TWOS_POWER : natural :=16;
	
	signal data_i : std_logic_vector(DATA_WIDTH - 1 downto 0) := (others => '0');
	signal data_o : std_logic_vector(DATA_WIDTH - 1 downto 0);
	signal data_en_i, clk, rst : std_logic:= '0';
	signal data_en_o : std_logic;
	signal ii : integer := 0;
	signal uu : real;

	-- for dut: iir_lpf_real use work.iir_lpf_real;

	--file output_buf : text;
begin
  -- Connect DUT
	dut:iir_lpf_real 
    	generic map(
			 DATA_WIDTH => DATA_WIDTH,
             FILTER_COEFF_TWOS_POWER => FILTER_COEFF_TWOS_POWER
		   )
	port map (
	    		 data_en_i => data_en_i,
			 data_i => data_i,
			 data_en_o => data_en_o,
			 data_o => data_o,
			 data_clk_i => clk,
			 data_rst_i => rst
		 );

	toggle_clk :process 
	begin
		clk <= '0';
		wait for T/2;
		clk <= '1';
		wait for T/2;
	end process toggle_clk;

	stimuli : process
	begin
	data_i <= (others => '0');
	data_en_i <= '0';
	rst <= '1', '0' after 3*T;
	wait for 2*T;

    for jj in 0 to 125000 loop	
		uu <= sin(real(jj)*2.0*MATH_PI*1.0*(125000.0**(-1))) ;-- + 1.0;
		data_i <= std_logic_vector(to_signed(integer(uu*2.0**(DATA_WIDTH-2)),DATA_WIDTH));
		wait until rising_edge(clk);
		wait for T;
		data_en_i <= '1';
		wait until rising_edge(clk);
		wait until rising_edge(clk);
		data_en_i <= '0';
	end loop;
        for jj in 0 to 125000 loop	
		uu <= sin(real(jj)*2.0*MATH_PI*10.0*(125000.0**(-1))) ;-- + 1.0;
		data_i <= std_logic_vector(to_signed(integer(uu*2.0**(DATA_WIDTH-2)),DATA_WIDTH));
		wait until rising_edge(clk);
		wait for T;
		data_en_i <= '1';
		wait until rising_edge(clk);
		wait until rising_edge(clk);
		data_en_i <= '0';
	end loop;
        for jj in 0 to 125000 loop	
		uu <= sin(real(jj)*2.0*MATH_PI*100.0*(125000.0**(-1))) ;-- + 1.0;
		data_i <= std_logic_vector(to_signed(integer(uu*2.0**(DATA_WIDTH-2)),DATA_WIDTH));
		wait until rising_edge(clk);
		wait for T;
		data_en_i <= '1';
		wait until rising_edge(clk);
		wait until rising_edge(clk);
		data_en_i <= '0';
	end loop;    
	assert false report "Test done." severity error;
	wait; 
	end process stimuli;
end tb;