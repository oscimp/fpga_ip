---------------------------------------------------------------------------
-- (c) Copyright: OscillatorIMP Digital
-- Author : Gwenhael Goavec-Merou<gwenhael.goavec-merou@trabucayre.com>
-- modified: Ivan Ryger <om1air@gmail.com>
-- Creation date : 2015/04/08
-- last modified : 2021/06/11
---------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
use IEEE.MATH_REAL.all;


library xil_defaultlib;
use xil_defaultlib.mylib.all;

entity MUXrealNto1_synch is
	generic (
	STAGES : natural := 3;
	REG_WIDTH: positive := 4
	);
	port (
		ref_clk_i : in std_logic;
		clk_i : in std_logic;
		data_i : in std_logic_vector(REG_WIDTH - 1 downto 0); -- ***
		data_o : out std_logic_vector(REG_WIDTH - 1 downto 0) -- ***
	);
end entity MUXrealNto1_synch;

architecture bhv of MUXrealNto1_synch is
	type STD_LOGIC_VECTOR_ARRAY is array(natural range<>) of std_logic_Vector(REG_WIDTH - 1 downto 0);

	signal sync_stage0_s: std_logic_vector(REG_WIDTH - 1 downto 0); -- ***	
	--signal flipflops : std_logic_vector(stages -1 downto 0) := (others => '0');
	--signal flipflops : std_logic_vector(STAGES*REG_WIDTH - 1 downto 0);
	--signal flipflops : STD_LOGIC_VECTOR_ARRAY_T(0 to STAGES - 1)(REG_WIDTH - 1 downto 0);
	signal flipflops  : STD_LOGIC_VECTOR_ARRAY(STAGES - 1 downto 0):= (others=>(others=>'0')); 
    --:= (others =>'0')
    
	attribute ASYNC_REG : string;
	attribute ASYNC_REG of flipflops: signal is "true";
begin
	ref_proc: process(ref_clk_i) begin
		if rising_edge(ref_clk_i) then
			sync_stage0_s <= data_i; -- ***
		end if;
	end process;

	sync_proc: process(clk_i)
	begin
	
	if rising_edge(clk_i) then
	   flipflops(0) <= sync_stage0_s;
       flipflops(STAGES - 1 downto 1) <= flipflops(STAGES - 2 downto 0);
	end if;
--gen_reg_chain: for j in 1 to 10 generate---!! cannot be used in process
	end process;
	data_o <= flipflops(stages-1);
end bhv;
