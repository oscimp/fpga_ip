-----------------------------------------------------------------------
-- (c) Copyright: OscillatorIMP Digital
-- Author : Ivan Ryger, ivan.ryger@femto-st.fr
-- Creation date : 2021/09/14
-- modification	 : 2021/11/8 IR - changed the component declaration unwrap_phase_diff.vhd : 
-- to accept generalized case of PI interval.
-----------------------------------------------------------------------
-- Cadence Xcelium 20.02 compile options -v200x -access +rw

-- idea of introducing inertia into instantaneous frequency estimation originally from
-- these Hugo Bergeron, Synthèse de fréquences optiques, Universite de Laval, 2016, p. 42-48

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity unwrap_phase_diff_tb is
end unwrap_phase_diff_tb;

architecture tb of unwrap_phase_diff_tb is 
	component unwrap_phase_diff is
	generic(
		DATA_WIDTH : natural :=16;
		DATA_OUT_WIDTH : natural := 32;
		PI_VALUE		: integer := 12868;         --M_PI*2**(NB_ITER - 1)
		FILTER_COEFF_TWOS_POWER : natural := 5;	-- determines the LP filter cutoff frequency
		ESTIMATION_METHOD : natural := 0 -- 0-- simple phase extraction, 1-simple phase and frequency extraction, 2- robust extraction of phase and frequency  

	);
	port(
		data_in : in std_logic_vector(DATA_WIDTH - 1 downto 0);
		data_en_i : in  std_logic;
        data_clk_i : in std_logic;
        data_rst_i : in std_logic;
		data_out : out std_logic_vector(DATA_OUT_WIDTH - 1 downto 0);
		data_en_o : out std_logic;
        data_clk_o : out std_logic;
        data_rst_o : out std_logic
	);
	end component unwrap_phase_diff;
	
	constant T : time := 8 ns;
    constant f : real := 1.0e+6;
    constant fs : real := 125.0e+6;
	constant DATA_WIDTH : natural := 16;
    constant PI_SCALING : natural := 12; 
	constant PI_VALUE : natural := 12868;-- 3.141*2**PI_SCALING    
	constant DATA_OUT_WIDTH : natural := 32;
    constant ESTIMATION_METHOD : natural := 2; --0: simple phase unwrap, 1: phase and frequency unwrap, 2: robust phase and frequency unwrap
	
	signal data_in : std_logic_vector(DATA_WIDTH - 1 downto 0);
	signal phase : std_logic_vector(DATA_WIDTH + 1 - 1 downto 0);
    signal uu, vv, nnu, nnv, ph : real;
	
	signal data_out : std_logic_vector(DATA_OUT_WIDTH - 1 downto 0);
	signal data_en_i, data_en_o, clk ,rst : std_logic;	
begin 
	dut : unwrap_phase_diff
	generic map( 
				DATA_WIDTH => DATA_WIDTH,
				DATA_OUT_WIDTH => DATA_OUT_WIDTH,
				PI_VALUE => PI_VALUE,
                ESTIMATION_METHOD => ESTIMATION_METHOD
				)
	port map	(
				data_in => data_in,
				data_en_i => data_en_i,
				data_out => data_out,
				data_en_o => data_en_o,
				data_clk_i => clk,
				data_rst_i=> rst
				);
				
	toggle_clk :process 
	begin
		clk <= '0';
		wait for T/2;
		clk <= '1';
		wait for T/2;
	end process toggle_clk;
	
	data_in <= std_logic_vector(resize(signed(phase),data_in'length));
	
	stimuli : process
        variable seed1, seed2 : positive;-- := 2;
    	variable x1, x2, xx1, xx2 : real;
        variable rand_min : real := 1.0E-10;
        variable rand_max : real := 1.0;
        variable sigma :real := 1.0e-1;
        
	begin
	report("test starts");
	rst <= '1';
	data_en_i <= '0';
    nnu <= 0.0;
    nnv <= 0.0;
	phase <= (others => '0');
	wait until rising_edge(clk);
	wait until rising_edge(clk);
	rst <= '0';
	wait until rising_edge(clk);
	data_en_i <= '1';
	wait until rising_edge(data_en_o);
	wait until rising_edge(clk);
	data_en_i <= '0';
	wait until rising_edge(clk);
    xx1:=0.0;
    xx2:=0.0;
	uniform(seed1, seed2, xx1);
    uniform(seed1, seed2, xx2);
    report("entering the loop");
    
	for ii in 0 to 100000 loop 
        uniform(seed1, seed2, xx1);
        uniform(seed1, seed2, xx2);  
        x1 := (rand_max - rand_min)*xx1 + rand_min;
        x2 := (rand_max - rand_min)*xx2 + rand_min;
        -- Box-Muller transform to map uniform random numbers to Gaussian noise
    	nnu <= sqrt(-2.0*log(x1))*cos(2.0*MATH_PI*x2)*sigma;
        nnv <= sqrt(-2.0*log(x1))*sin(2.0*MATH_PI*x2)*sigma; 
        uu <= cos(real(ii)*f/fs*2.0*MATH_PI) + nnu;
        vv <= sin(real(ii)*f/fs*2.0*MATH_PI) + nnv;
        --https://perso.telecom-paristech.fr/guilley/ENS/20171205/TP/tp_syn/doc/IEEE_VHDL_1076.2-1996.pdf
        ph <= arctan(vv,uu);
    	phase <= std_logic_vector(to_signed(integer(ph*2.0**PI_SCALING), phase'length));
		data_en_i <= '1';
		wait until rising_edge(clk);
		data_en_i <= '0';
		wait until rising_edge(clk);
	end loop;
	
	assert false report "test done" severity error;
	wait;
	end process stimuli;
end tb;
