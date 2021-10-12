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

--library xil_defaultlib;
--use xil_defaultlib.mylib.all; 


entity MUXrealNto1 is
	generic 
	(   
	    ID : NATURAL := 1;
		INPUTS : positive range 1 to 32 := 4;
	--	DEFAULT_INPUT : natural := 0;
		DATA_SIZE : natural := 16;
		C_S00_AXI_DATA_WIDTH	: integer	:= 32;
		C_S00_AXI_ADDR_WIDTH	: integer	:= 4
	);
	port (
		--processing
		data_0_i_i   : in STD_LOGIC_VECTOR(DATA_SIZE -1 downto 0) := (others => '0');
		data_0_en_i  : in STD_LOGIC := '0';
		data_0_clk_i : in STD_LOGIC := '0';
		data_0_eof_i : in STD_LOGIC := '0';
		data_0_rst_i : in STD_LOGIC := '0';

		data_1_i_i   : in STD_LOGIC_VECTOR(DATA_SIZE -1 downto 0) := (others => '0');
		data_1_en_i  : in STD_LOGIC := '0';
		data_1_clk_i : in STD_LOGIC := '0';
		data_1_eof_i : in STD_LOGIC := '0';
		data_1_rst_i : in STD_LOGIC := '0';

		data_2_i_i   : in STD_LOGIC_VECTOR(DATA_SIZE -1 downto 0) := (others => '0');
		data_2_en_i  : in STD_LOGIC := '0';
		data_2_clk_i : in STD_LOGIC := '0';
		data_2_eof_i : in STD_LOGIC := '0';
		data_2_rst_i : in STD_LOGIC := '0';

		data_3_i_i   : in STD_LOGIC_VECTOR(DATA_SIZE -1 downto 0) := (others => '0');
		data_3_en_i  : in STD_LOGIC := '0';
		data_3_clk_i : in STD_LOGIC := '0';
		data_3_eof_i : in STD_LOGIC := '0';
		data_3_rst_i : in STD_LOGIC := '0';

		data_4_i_i   : in STD_LOGIC_VECTOR(DATA_SIZE -1 downto 0) := (others => '0');
		data_4_en_i  : in STD_LOGIC := '0';
		data_4_clk_i : in STD_LOGIC := '0';
		data_4_eof_i : in STD_LOGIC := '0';
		data_4_rst_i : in STD_LOGIC := '0';

		data_5_i_i   : in STD_LOGIC_VECTOR(DATA_SIZE -1 downto 0) := (others => '0');
		data_5_en_i  : in STD_LOGIC := '0';
		data_5_clk_i : in STD_LOGIC := '0';
		data_5_eof_i : in STD_LOGIC := '0';
		data_5_rst_i : in STD_LOGIC := '0';

		data_6_i_i   : in STD_LOGIC_VECTOR(DATA_SIZE -1 downto 0) := (others => '0');
		data_6_en_i  : in STD_LOGIC := '0';
		data_6_clk_i : in STD_LOGIC := '0';
		data_6_eof_i : in STD_LOGIC := '0';
		data_6_rst_i : in STD_LOGIC := '0';

		data_7_i_i   : in STD_LOGIC_VECTOR(DATA_SIZE -1 downto 0) := (others => '0');
		data_7_en_i  : in STD_LOGIC := '0';
		data_7_clk_i : in STD_LOGIC := '0';
		data_7_eof_i : in STD_LOGIC := '0';
		data_7_rst_i : in STD_LOGIC := '0';

		data_8_i_i   : in STD_LOGIC_VECTOR(DATA_SIZE -1 downto 0) := (others => '0');
		data_8_en_i  : in STD_LOGIC := '0';
		data_8_clk_i : in STD_LOGIC := '0';
		data_8_eof_i : in STD_LOGIC := '0';
		data_8_rst_i : in STD_LOGIC := '0';

		data_9_i_i   : in STD_LOGIC_VECTOR(DATA_SIZE -1 downto 0) := (others => '0');
		data_9_en_i  : in STD_LOGIC := '0';
		data_9_clk_i : in STD_LOGIC := '0';
		data_9_eof_i : in STD_LOGIC := '0';
		data_9_rst_i : in STD_LOGIC := '0';

		data_10_i_i   : in STD_LOGIC_VECTOR(DATA_SIZE -1 downto 0) := (others => '0');
		data_10_en_i  : in STD_LOGIC := '0';
		data_10_clk_i : in STD_LOGIC := '0';
		data_10_eof_i : in STD_LOGIC := '0';
		data_10_rst_i : in STD_LOGIC := '0';

		data_11_i_i   : in STD_LOGIC_VECTOR(DATA_SIZE -1 downto 0) := (others => '0');
		data_11_en_i  : in STD_LOGIC := '0';
		data_11_clk_i : in STD_LOGIC := '0';
		data_11_eof_i : in STD_LOGIC := '0';
		data_11_rst_i : in STD_LOGIC := '0';

		data_12_i_i   : in STD_LOGIC_VECTOR(DATA_SIZE -1 downto 0) := (others => '0');
		data_12_en_i  : in STD_LOGIC := '0';
		data_12_clk_i : in STD_LOGIC := '0';
		data_12_eof_i : in STD_LOGIC := '0';
		data_12_rst_i : in STD_LOGIC := '0';

		data_13_i_i   : in STD_LOGIC_VECTOR(DATA_SIZE -1 downto 0) := (others => '0');
		data_13_en_i  : in STD_LOGIC := '0';
		data_13_clk_i : in STD_LOGIC := '0';
		data_13_eof_i : in STD_LOGIC := '0';
		data_13_rst_i : in STD_LOGIC := '0';

		data_14_i_i   : in STD_LOGIC_VECTOR(DATA_SIZE -1 downto 0) := (others => '0');
		data_14_en_i  : in STD_LOGIC := '0';
		data_14_clk_i : in STD_LOGIC := '0';
		data_14_eof_i : in STD_LOGIC := '0';
		data_14_rst_i : in STD_LOGIC := '0';

		data_15_i_i   : in STD_LOGIC_VECTOR(DATA_SIZE -1 downto 0) := (others => '0');
		data_15_en_i  : in STD_LOGIC := '0';
		data_15_clk_i : in STD_LOGIC := '0';
		data_15_eof_i : in STD_LOGIC := '0';
		data_15_rst_i : in STD_LOGIC := '0';

		data_16_i_i   : in STD_LOGIC_VECTOR(DATA_SIZE -1 downto 0) := (others => '0');
		data_16_en_i  : in STD_LOGIC := '0';
		data_16_clk_i : in STD_LOGIC := '0';
		data_16_eof_i : in STD_LOGIC := '0';
		data_16_rst_i : in STD_LOGIC := '0';

		data_17_i_i   : in STD_LOGIC_VECTOR(DATA_SIZE -1 downto 0) := (others => '0');
		data_17_en_i  : in STD_LOGIC := '0';
		data_17_clk_i : in STD_LOGIC := '0';
		data_17_eof_i : in STD_LOGIC := '0';
		data_17_rst_i : in STD_LOGIC := '0';

		data_18_i_i   : in STD_LOGIC_VECTOR(DATA_SIZE -1 downto 0) := (others => '0');
		data_18_en_i  : in STD_LOGIC := '0';
		data_18_clk_i : in STD_LOGIC := '0';
		data_18_eof_i : in STD_LOGIC := '0';
		data_18_rst_i : in STD_LOGIC := '0';

		data_19_i_i   : in STD_LOGIC_VECTOR(DATA_SIZE -1 downto 0) := (others => '0');
		data_19_en_i  : in STD_LOGIC := '0';
		data_19_clk_i : in STD_LOGIC := '0';
		data_19_eof_i : in STD_LOGIC := '0';
		data_19_rst_i : in STD_LOGIC := '0';

		data_20_i_i   : in STD_LOGIC_VECTOR(DATA_SIZE -1 downto 0) := (others => '0');
		data_20_en_i  : in STD_LOGIC := '0';
		data_20_clk_i : in STD_LOGIC := '0';
		data_20_eof_i : in STD_LOGIC := '0';
		data_20_rst_i : in STD_LOGIC := '0';

		data_21_i_i   : in STD_LOGIC_VECTOR(DATA_SIZE -1 downto 0) := (others => '0');
		data_21_en_i  : in STD_LOGIC := '0';
		data_21_clk_i : in STD_LOGIC := '0';
		data_21_eof_i : in STD_LOGIC := '0';
		data_21_rst_i : in STD_LOGIC := '0';

		data_22_i_i   : in STD_LOGIC_VECTOR(DATA_SIZE -1 downto 0) := (others => '0');
		data_22_en_i  : in STD_LOGIC := '0';
		data_22_clk_i : in STD_LOGIC := '0';
		data_22_eof_i : in STD_LOGIC := '0';
		data_22_rst_i : in STD_LOGIC := '0';

		data_23_i_i   : in STD_LOGIC_VECTOR(DATA_SIZE -1 downto 0) := (others => '0');
		data_23_en_i  : in STD_LOGIC := '0';
		data_23_clk_i : in STD_LOGIC := '0';
		data_23_eof_i : in STD_LOGIC := '0';
		data_23_rst_i : in STD_LOGIC := '0';

		data_24_i_i   : in STD_LOGIC_VECTOR(DATA_SIZE -1 downto 0) := (others => '0');
		data_24_en_i  : in STD_LOGIC := '0';
		data_24_clk_i : in STD_LOGIC := '0';
		data_24_eof_i : in STD_LOGIC := '0';
		data_24_rst_i : in STD_LOGIC := '0';

		data_25_i_i   : in STD_LOGIC_VECTOR(DATA_SIZE -1 downto 0) := (others => '0');
		data_25_en_i  : in STD_LOGIC := '0';
		data_25_clk_i : in STD_LOGIC := '0';
		data_25_eof_i : in STD_LOGIC := '0';
		data_25_rst_i : in STD_LOGIC := '0';

		data_26_i_i   : in STD_LOGIC_VECTOR(DATA_SIZE -1 downto 0) := (others => '0');
		data_26_en_i  : in STD_LOGIC := '0';
		data_26_clk_i : in STD_LOGIC := '0';
		data_26_eof_i : in STD_LOGIC := '0';
		data_26_rst_i : in STD_LOGIC := '0';

		data_27_i_i   : in STD_LOGIC_VECTOR(DATA_SIZE -1 downto 0) := (others => '0');
		data_27_en_i  : in STD_LOGIC := '0';
		data_27_clk_i : in STD_LOGIC := '0';
		data_27_eof_i : in STD_LOGIC := '0';
		data_27_rst_i : in STD_LOGIC := '0';

		data_28_i_i   : in STD_LOGIC_VECTOR(DATA_SIZE -1 downto 0) := (others => '0');
		data_28_en_i  : in STD_LOGIC := '0';
		data_28_clk_i : in STD_LOGIC := '0';
		data_28_eof_i : in STD_LOGIC := '0';
		data_28_rst_i : in STD_LOGIC := '0';

		data_29_i_i   : in STD_LOGIC_VECTOR(DATA_SIZE -1 downto 0) := (others => '0');
		data_29_en_i  : in STD_LOGIC := '0';
		data_29_clk_i : in STD_LOGIC := '0';
		data_29_eof_i : in STD_LOGIC := '0';
		data_29_rst_i : in STD_LOGIC := '0';

		data_30_i_i   : in STD_LOGIC_VECTOR(DATA_SIZE -1 downto 0) := (others => '0');
		data_30_en_i  : in STD_LOGIC := '0';
		data_30_clk_i : in STD_LOGIC := '0';
		data_30_eof_i : in STD_LOGIC := '0';
		data_30_rst_i : in STD_LOGIC := '0';

		data_31_i_i   : in STD_LOGIC_VECTOR(DATA_SIZE -1 downto 0) := (others => '0');
		data_31_en_i  : in STD_LOGIC := '0';
		data_31_clk_i : in STD_LOGIC := '0';
		data_31_eof_i : in STD_LOGIC := '0';
		data_31_rst_i : in STD_LOGIC := '0';
      
      --  select_i    : in STD_LOGIC_VECTOR(integer(log2(real(INPUTS))) - 1 downto 0);
        
		data_i_o	: out STD_LOGIC_VECTOR(DATA_SIZE-1 downto 0);
		data_en_o	: out STD_LOGIC;
        data_clk_o	: out STD_LOGIC;
	    data_eof_o	: out STD_LOGIC;
		data_rst_o	: out STD_LOGIC;
		
		
		s00_axi_aclk	: in std_logic;
		s00_axi_reset	: in std_logic;
		s00_axi_awaddr	: in std_logic_vector(C_S00_AXI_ADDR_WIDTH-1 downto 0);
		--s00_axi_awprot	: in std_logic_vector(2 downto 0);
		s00_axi_awvalid	: in std_logic;
		s00_axi_awready	: out std_logic;
		s00_axi_wdata	: in std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
		--s00_axi_wstrb	: in std_logic_vector((C_S00_AXI_DATA_WIDTH/8)-1 downto 0);
		s00_axi_wvalid	: in std_logic;
		s00_axi_wready	: out std_logic;
		s00_axi_bresp	: out std_logic_vector(1 downto 0);
		s00_axi_bvalid	: out std_logic;
		s00_axi_bready	: in std_logic;
		s00_axi_araddr	: in std_logic_vector(C_S00_AXI_ADDR_WIDTH-1 downto 0);
		--s00_axi_arprot	: in std_logic_vector(2 downto 0);
		s00_axi_arvalid	: in std_logic;
		s00_axi_arready	: out std_logic;
		s00_axi_rdata	: out std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
		s00_axi_rresp	: out std_logic_vector(1 downto 0);
		s00_axi_rvalid	: out std_logic;
        s00_axi_rready	: in std_logic
    );   
 
end MUXrealNto1;

architecture Behavioral of MUXrealNto1 is
	constant SEL_SIZE : integer := integer(ceil(log2(real(INPUTS))));
	
	type STD_LOGIC_VECTOR_ARRAY is array(natural range <>) of STD_LOGIC_VECTOR(DATA_SIZE - 1 downto 0);
	type STD_LOGIC_ARRAY is array(natural range <>) of STD_LOGIC;

	signal addr_s : std_logic_vector(1 downto 0);
	signal write_en_s, read_en_s : std_logic;
	--signal witchIn : std_logic;
	signal select_s, select_s_sync : std_logic_vector(SEL_SIZE - 1 downto 0) := (others => '0');
	signal witchIn_sync: std_logic;

	signal data_i_s : STD_LOGIC_VECTOR_ARRAY(0 to INPUTS - 1):= (others =>(others => '0'));
	signal data_en_s  : STD_LOGIC_ARRAY(INPUTS - 1 downto 0):= (others =>'0');
	signal data_clk_s : STD_LOGIC_ARRAY(INPUTS - 1 downto 0):= (others =>'0');
	signal data_eof_s : STD_LOGIC_ARRAY(INPUTS - 1 downto 0):= (others =>'0');
	signal data_rst_s : STD_LOGIC_ARRAY(INPUTS - 1 downto 0):= (others =>'0');


begin
		data_i_s(0) <= data_0_i_i;
		data_en_s(0) <= data_0_en_i;
		data_clk_s(0) <= data_0_clk_i;
		data_eof_s(0) <= data_0_eof_i;
		data_rst_s(0) <= data_0_rst_i;
	input1: if INPUTS > 1 generate
		data_i_s(1) <= data_1_i_i;
		data_en_s(1) <= data_1_en_i;
		data_clk_s(1) <= data_1_clk_i;
		data_eof_s(1) <= data_1_eof_i;
		data_rst_s(1) <= data_1_rst_i;
	end generate input1;
	input2: if INPUTS > 2 generate
		data_i_s(2) <= data_2_i_i;
		data_en_s(2) <= data_2_en_i;
		data_clk_s(2) <= data_2_clk_i;
		data_eof_s(2) <= data_2_eof_i;
		data_rst_s(2) <= data_2_rst_i;
	end generate input2;
	input3: if INPUTS > 3 generate
		data_i_s(3) <= data_3_i_i;
		data_en_s(3) <= data_3_en_i;
		data_clk_s(3) <= data_3_clk_i;
		data_eof_s(3) <= data_3_eof_i;
		data_rst_s(3) <= data_3_rst_i;
	end generate input3;
	input4: if INPUTS > 4 generate
		data_i_s(4) <= data_4_i_i;
		data_en_s(4) <= data_4_en_i;
		data_clk_s(4) <= data_4_clk_i;
		data_eof_s(4) <= data_4_eof_i;
		data_rst_s(4) <= data_4_rst_i;
	end generate input4;
	input5: if INPUTS > 5 generate
		data_i_s(5) <= data_5_i_i;
		data_en_s(5) <= data_5_en_i;
		data_clk_s(5) <= data_5_clk_i;
		data_eof_s(5) <= data_5_eof_i;
		data_rst_s(5) <= data_5_rst_i;
	end generate input5;
	input6: if INPUTS > 6 generate
		data_i_s(6) <= data_6_i_i;
		data_en_s(6) <= data_6_en_i;
		data_clk_s(6) <= data_6_clk_i;
		data_eof_s(6) <= data_6_eof_i;
		data_rst_s(6) <= data_6_rst_i;
	end generate input6;
	input7: if INPUTS > 7 generate
		data_i_s(7) <= data_7_i_i;
		data_en_s(7) <= data_7_en_i;
		data_clk_s(7) <= data_7_clk_i;
		data_eof_s(7) <= data_7_eof_i;
		data_rst_s(7) <= data_7_rst_i;
	end generate input7;
	input8: if INPUTS > 8 generate
		data_i_s(8) <= data_8_i_i;
		data_en_s(8) <= data_8_en_i;
		data_clk_s(8) <= data_8_clk_i;
		data_eof_s(8) <= data_8_eof_i;
		data_rst_s(8) <= data_8_rst_i;
	end generate input8;
	input9: if INPUTS > 9 generate
		data_i_s(9) <= data_9_i_i;
		data_en_s(9) <= data_9_en_i;
		data_clk_s(9) <= data_9_clk_i;
		data_eof_s(9) <= data_9_eof_i;
		data_rst_s(9) <= data_9_rst_i;
	end generate input9;
	input10: if INPUTS > 10 generate
		data_i_s(10) <= data_10_i_i;
		data_en_s(10) <= data_10_en_i;
		data_clk_s(10) <= data_10_clk_i;
		data_eof_s(10) <= data_10_eof_i;
		data_rst_s(10) <= data_10_rst_i;
	end generate input10;
	input11: if INPUTS > 11 generate
		data_i_s(11) <= data_11_i_i;
		data_en_s(11) <= data_11_en_i;
		data_clk_s(11) <= data_11_clk_i;
		data_eof_s(11) <= data_11_eof_i;
		data_rst_s(11) <= data_11_rst_i;
	end generate input11;
	input12: if INPUTS > 12 generate
		data_i_s(12) <= data_12_i_i;
		data_en_s(12) <= data_12_en_i;
		data_clk_s(12) <= data_12_clk_i;
		data_eof_s(12) <= data_12_eof_i;
		data_rst_s(12) <= data_12_rst_i;
	end generate input12;
	input13: if INPUTS > 13 generate
		data_i_s(13) <= data_13_i_i;
		data_en_s(13) <= data_13_en_i;
		data_clk_s(13) <= data_13_clk_i;
		data_eof_s(13) <= data_13_eof_i;
		data_rst_s(13) <= data_13_rst_i;
	end generate input13;
	input14: if INPUTS > 14 generate
		data_i_s(14) <= data_14_i_i;
		data_en_s(14) <= data_14_en_i;
		data_clk_s(14) <= data_14_clk_i;
		data_eof_s(14) <= data_14_eof_i;
		data_rst_s(14) <= data_14_rst_i;
	end generate input14;
	input15: if INPUTS > 15 generate
		data_i_s(15) <= data_15_i_i;
		data_en_s(15) <= data_15_en_i;
		data_clk_s(15) <= data_15_clk_i;
		data_eof_s(15) <= data_15_eof_i;
		data_rst_s(15) <= data_15_rst_i;
	end generate input15;
	input16: if INPUTS > 16 generate
		data_i_s(16) <= data_16_i_i;
		data_en_s(16) <= data_16_en_i;
		data_clk_s(16) <= data_16_clk_i;
		data_eof_s(16) <= data_16_eof_i;
		data_rst_s(16) <= data_16_rst_i;
	end generate input16;
	input17: if INPUTS > 17 generate
		data_i_s(17) <= data_17_i_i;
		data_en_s(17) <= data_17_en_i;
		data_clk_s(17) <= data_17_clk_i;
		data_eof_s(17) <= data_17_eof_i;
		data_rst_s(17) <= data_17_rst_i;
	end generate input17;
	input18: if INPUTS > 18 generate
		data_i_s(18) <= data_18_i_i;
		data_en_s(18) <= data_18_en_i;
		data_clk_s(18) <= data_18_clk_i;
		data_eof_s(18) <= data_18_eof_i;
		data_rst_s(18) <= data_18_rst_i;
	end generate input18;
	input19: if INPUTS > 19 generate
		data_i_s(19) <= data_19_i_i;
		data_en_s(19) <= data_19_en_i;
		data_clk_s(19) <= data_19_clk_i;
		data_eof_s(19) <= data_19_eof_i;
		data_rst_s(19) <= data_19_rst_i;
	end generate input19;
	input20: if INPUTS > 20 generate
		data_i_s(20) <= data_20_i_i;
		data_en_s(20) <= data_20_en_i;
		data_clk_s(20) <= data_20_clk_i;
		data_eof_s(20) <= data_20_eof_i;
		data_rst_s(20) <= data_20_rst_i;
	end generate input20;
	input21: if INPUTS > 21 generate
		data_i_s(21) <= data_21_i_i;
		data_en_s(21) <= data_21_en_i;
		data_clk_s(21) <= data_21_clk_i;
		data_eof_s(21) <= data_21_eof_i;
		data_rst_s(21) <= data_21_rst_i;
	end generate input21;
	input22: if INPUTS > 22 generate
		data_i_s(22) <= data_22_i_i;
		data_en_s(22) <= data_22_en_i;
		data_clk_s(22) <= data_22_clk_i;
		data_eof_s(22) <= data_22_eof_i;
		data_rst_s(22) <= data_22_rst_i;
	end generate input22;
	input23: if INPUTS > 23 generate
		data_i_s(23) <= data_23_i_i;
		data_en_s(23) <= data_23_en_i;
		data_clk_s(23) <= data_23_clk_i;
		data_eof_s(23) <= data_23_eof_i;
		data_rst_s(23) <= data_23_rst_i;
	end generate input23;
	input24: if INPUTS > 24 generate
		data_i_s(24) <= data_24_i_i;
		data_en_s(24) <= data_24_en_i;
		data_clk_s(24) <= data_24_clk_i;
		data_eof_s(24) <= data_24_eof_i;
		data_rst_s(24) <= data_24_rst_i;
	end generate input24;
	input25: if INPUTS > 25 generate
		data_i_s(25) <= data_25_i_i;
		data_en_s(25) <= data_25_en_i;
		data_clk_s(25) <= data_25_clk_i;
		data_eof_s(25) <= data_25_eof_i;
		data_rst_s(25) <= data_25_rst_i;
	end generate input25;
	input26: if INPUTS > 26 generate
		data_i_s(26) <= data_26_i_i;
		data_en_s(26) <= data_26_en_i;
		data_clk_s(26) <= data_26_clk_i;
		data_eof_s(26) <= data_26_eof_i;
		data_rst_s(26) <= data_26_rst_i;
	end generate input26;
	input27: if INPUTS > 27 generate
		data_i_s(27) <= data_27_i_i;
		data_en_s(27) <= data_27_en_i;
		data_clk_s(27) <= data_27_clk_i;
		data_eof_s(27) <= data_27_eof_i;
		data_rst_s(27) <= data_27_rst_i;
	end generate input27;
	input28: if INPUTS > 28 generate
		data_i_s(28) <= data_28_i_i;
		data_en_s(28) <= data_28_en_i;
		data_clk_s(28) <= data_28_clk_i;
		data_eof_s(28) <= data_28_eof_i;
		data_rst_s(28) <= data_28_rst_i;
	end generate input28;
	input29: if INPUTS > 29 generate
		data_i_s(29) <= data_29_i_i;
		data_en_s(29) <= data_29_en_i;
		data_clk_s(29) <= data_29_clk_i;
		data_eof_s(29) <= data_29_eof_i;
		data_rst_s(29) <= data_29_rst_i;
	end generate input29;
	input30: if INPUTS > 30 generate
		data_i_s(30) <= data_30_i_i;
		data_en_s(30) <= data_30_en_i;
		data_clk_s(30) <= data_30_clk_i;
		data_eof_s(30) <= data_30_eof_i;
		data_rst_s(30) <= data_30_rst_i;
	end generate input30;
	input31: if INPUTS > 31 generate
		data_i_s(31) <= data_31_i_i;
		data_en_s(31) <= data_31_en_i;
		data_clk_s(31) <= data_31_clk_i;
		data_eof_s(31) <= data_31_eof_i;
		data_rst_s(31) <= data_31_rst_i;
	end generate input31;
-- multiplexor routine
    data_i_o   <= data_i_s(to_integer(unsigned(select_s)));
    data_en_o  <= data_en_s(to_integer(unsigned(select_s)));
    data_clk_o <= data_clk_s(to_integer(unsigned(select_s)));
    data_eof_o <= data_eof_s(to_integer(unsigned(select_s)));
    data_rst_o <= data_rst_s(to_integer(unsigned(select_s)));

--clock domain synchronizer 
MUXrealNto1_synch_inst: entity work.MUXrealNto1_synch
	generic map(
		REG_WIDTH => SEL_SIZE
		)
	port map (
		ref_clk_i => s00_axi_aclk, clk_i => data_0_clk_i,
		data_i => select_s,	data_o => select_s_sync
	);


--inteface between AXI and MUX block
    MUXrealWb_inst : entity work.MUXrealNto1_wb
    generic map(
        id        => id,
--		DEFAULT_INPUT => DEFAULT_INPUT,
        wb_size   => C_S00_AXI_DATA_WIDTH, -- Data port size for wishbone
        SEL_SIZE => SEL_SIZE
    )
    port map(
		-- Syscon signals
		reset     => s00_axi_reset,
		clk       => s00_axi_aclk,
		-- Wishbone signals
		wbs_add       => addr_s,       
		wbs_write     => write_en_s,     
		wbs_writedata => s00_axi_wdata, 
		wbs_read     => read_en_s,     
		wbs_readdata  => s00_axi_rdata,  
		outputselect => select_s
    );
    
    	-- Instantiation of Axi Bus Interface S00_AXI
	handle_comm : entity work.MUXreal_handComm
	generic map (
		C_S_AXI_DATA_WIDTH	=> C_S00_AXI_DATA_WIDTH,
		C_S_AXI_ADDR_WIDTH	=> C_S00_AXI_ADDR_WIDTH
	)
	port map (
		S_AXI_ACLK		=> s00_axi_aclk,
		S_AXI_RESET		=> s00_axi_reset,
		S_AXI_AWADDR	=> s00_axi_awaddr,
		--S_AXI_AWPROT	=> s00_axi_awprot,
		S_AXI_AWVALID	=> s00_axi_awvalid,
		S_AXI_AWREADY	=> s00_axi_awready,
		--S_AXI_WSTRB	=> s00_axi_wstrb,
		S_AXI_WVALID	=> s00_axi_wvalid,
		S_AXI_WREADY	=> s00_axi_wready,
		S_AXI_BRESP	=> s00_axi_bresp,
		S_AXI_BVALID	=> s00_axi_bvalid,
		S_AXI_BREADY	=> s00_axi_bready,
		S_AXI_ARADDR	=> s00_axi_araddr,
		--S_AXI_ARPROT	=> s00_axi_arprot,
		S_AXI_ARVALID	=> s00_axi_arvalid,
		S_AXI_ARREADY	=> s00_axi_arready,
		S_AXI_RRESP	=> s00_axi_rresp,
		S_AXI_RVALID	=> s00_axi_rvalid,
		S_AXI_RREADY	=> s00_axi_rready,
		read_en_o => read_en_s,
		write_en_o => write_en_s,
		addr_o => addr_s
	);
end Behavioral;
