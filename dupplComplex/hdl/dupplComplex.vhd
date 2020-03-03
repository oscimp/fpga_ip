---------------------------------------------------------------------------
-- (c) Copyright: OscillatorIMP Digital
-- Author : Gwenhael Goavec-Merou<gwenhael.goavec-merou@trabucayre.com>
-- Creation date : 2014/10/14
---------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;
entity dupplComplex is
	generic (
		NB_OUTPUT  : natural := 32;
		DATA_SIZE : natural := 8
	);
	port (
		-- DATA in
		data_en_i : in std_logic;
		data_clk_i : in std_logic;
		data_rst_i : in std_logic;
		data_eof_i : in std_logic;
		data_sof_i : in std_logic;
		data_i_i : in std_logic_vector(DATA_SIZE-1 downto 0);
		data_q_i : in std_logic_vector(DATA_SIZE-1 downto 0);
		--next
		data1_en_o : out std_logic;
		data1_clk_o : out std_logic;
		data1_rst_o : out std_logic;
		data1_eof_o : out std_logic;
		data1_sof_o : out std_logic;
		data1_i_o : out std_logic_vector(DATA_SIZE-1 downto 0);
		data1_q_o : out std_logic_vector(DATA_SIZE-1 downto 0);
		data2_en_o : out std_logic;
		data2_clk_o : out std_logic;
		data2_rst_o : out std_logic;
		data2_eof_o : out std_logic;
		data2_sof_o : out std_logic;
		data2_i_o : out std_logic_vector(DATA_SIZE-1 downto 0);
		data2_q_o : out std_logic_vector(DATA_SIZE-1 downto 0);
		data3_en_o : out std_logic;
		data3_clk_o : out std_logic;
		data3_rst_o : out std_logic;
		data3_eof_o : out std_logic;
		data3_sof_o : out std_logic;
		data3_i_o : out std_logic_vector(DATA_SIZE-1 downto 0);
		data3_q_o : out std_logic_vector(DATA_SIZE-1 downto 0);
		data4_en_o : out std_logic;
		data4_clk_o : out std_logic;
		data4_rst_o : out std_logic;
		data4_eof_o : out std_logic;
		data4_sof_o : out std_logic;
		data4_i_o : out std_logic_vector(DATA_SIZE-1 downto 0);
		data4_q_o : out std_logic_vector(DATA_SIZE-1 downto 0);
		data5_en_o : out std_logic;
		data5_clk_o : out std_logic;
		data5_rst_o : out std_logic;
		data5_eof_o : out std_logic;
		data5_sof_o : out std_logic;
		data5_i_o : out std_logic_vector(DATA_SIZE-1 downto 0);
		data5_q_o : out std_logic_vector(DATA_SIZE-1 downto 0);
		data6_en_o : out std_logic;
		data6_clk_o : out std_logic;
		data6_rst_o : out std_logic;
		data6_eof_o : out std_logic;
		data6_sof_o : out std_logic;
		data6_i_o : out std_logic_vector(DATA_SIZE-1 downto 0);
		data6_q_o : out std_logic_vector(DATA_SIZE-1 downto 0);
		data7_en_o : out std_logic;
		data7_clk_o : out std_logic;
		data7_rst_o : out std_logic;
		data7_eof_o : out std_logic;
		data7_sof_o : out std_logic;
		data7_i_o : out std_logic_vector(DATA_SIZE-1 downto 0);
		data7_q_o : out std_logic_vector(DATA_SIZE-1 downto 0);
		data8_en_o : out std_logic;
		data8_clk_o : out std_logic;
		data8_rst_o : out std_logic;
		data8_eof_o : out std_logic;
		data8_sof_o : out std_logic;
		data8_i_o : out std_logic_vector(DATA_SIZE-1 downto 0);
		data8_q_o : out std_logic_vector(DATA_SIZE-1 downto 0);
		data9_en_o : out std_logic;
		data9_clk_o : out std_logic;
		data9_rst_o : out std_logic;
		data9_eof_o : out std_logic;
		data9_sof_o : out std_logic;
		data9_i_o : out std_logic_vector(DATA_SIZE-1 downto 0);
		data9_q_o : out std_logic_vector(DATA_SIZE-1 downto 0);
		data10_en_o : out std_logic;
		data10_clk_o : out std_logic;
		data10_rst_o : out std_logic;
		data10_eof_o : out std_logic;
		data10_sof_o : out std_logic;
		data10_i_o : out std_logic_vector(DATA_SIZE-1 downto 0);
		data10_q_o : out std_logic_vector(DATA_SIZE-1 downto 0);
		data11_en_o : out std_logic;
		data11_clk_o : out std_logic;
		data11_rst_o : out std_logic;
		data11_eof_o : out std_logic;
		data11_sof_o : out std_logic;
		data11_i_o : out std_logic_vector(DATA_SIZE-1 downto 0);
		data11_q_o : out std_logic_vector(DATA_SIZE-1 downto 0);
		data12_en_o : out std_logic;
		data12_clk_o : out std_logic;
		data12_rst_o : out std_logic;
		data12_eof_o : out std_logic;
		data12_sof_o : out std_logic;
		data12_i_o : out std_logic_vector(DATA_SIZE-1 downto 0);
		data12_q_o : out std_logic_vector(DATA_SIZE-1 downto 0);
		data13_en_o : out std_logic;
		data13_clk_o : out std_logic;
		data13_rst_o : out std_logic;
		data13_eof_o : out std_logic;
		data13_sof_o : out std_logic;
		data13_i_o : out std_logic_vector(DATA_SIZE-1 downto 0);
		data13_q_o : out std_logic_vector(DATA_SIZE-1 downto 0);
		data14_en_o : out std_logic;
		data14_clk_o : out std_logic;
		data14_rst_o : out std_logic;
		data14_eof_o : out std_logic;
		data14_sof_o : out std_logic;
		data14_i_o : out std_logic_vector(DATA_SIZE-1 downto 0);
		data14_q_o : out std_logic_vector(DATA_SIZE-1 downto 0);
		data15_en_o : out std_logic;
		data15_clk_o : out std_logic;
		data15_rst_o : out std_logic;
		data15_eof_o : out std_logic;
		data15_sof_o : out std_logic;
		data15_i_o : out std_logic_vector(DATA_SIZE-1 downto 0);
		data15_q_o : out std_logic_vector(DATA_SIZE-1 downto 0);
		data16_en_o : out std_logic;
		data16_clk_o : out std_logic;
		data16_rst_o : out std_logic;
		data16_eof_o : out std_logic;
		data16_sof_o : out std_logic;
		data16_i_o : out std_logic_vector(DATA_SIZE-1 downto 0);
		data16_q_o : out std_logic_vector(DATA_SIZE-1 downto 0);
		data17_en_o : out std_logic;
		data17_clk_o : out std_logic;
		data17_rst_o : out std_logic;
		data17_eof_o : out std_logic;
		data17_sof_o : out std_logic;
		data17_i_o : out std_logic_vector(DATA_SIZE-1 downto 0);
		data17_q_o : out std_logic_vector(DATA_SIZE-1 downto 0);
		data18_en_o : out std_logic;
		data18_clk_o : out std_logic;
		data18_rst_o : out std_logic;
		data18_eof_o : out std_logic;
		data18_sof_o : out std_logic;
		data18_i_o : out std_logic_vector(DATA_SIZE-1 downto 0);
		data18_q_o : out std_logic_vector(DATA_SIZE-1 downto 0);
		data19_en_o : out std_logic;
		data19_clk_o : out std_logic;
		data19_rst_o : out std_logic;
		data19_eof_o : out std_logic;
		data19_sof_o : out std_logic;
		data19_i_o : out std_logic_vector(DATA_SIZE-1 downto 0);
		data19_q_o : out std_logic_vector(DATA_SIZE-1 downto 0);
		data20_en_o : out std_logic;
		data20_clk_o : out std_logic;
		data20_rst_o : out std_logic;
		data20_eof_o : out std_logic;
		data20_sof_o : out std_logic;
		data20_i_o : out std_logic_vector(DATA_SIZE-1 downto 0);
		data20_q_o : out std_logic_vector(DATA_SIZE-1 downto 0);
		data21_en_o : out std_logic;
		data21_clk_o : out std_logic;
		data21_rst_o : out std_logic;
		data21_eof_o : out std_logic;
		data21_sof_o : out std_logic;
		data21_i_o : out std_logic_vector(DATA_SIZE-1 downto 0);
		data21_q_o : out std_logic_vector(DATA_SIZE-1 downto 0);
		data22_en_o : out std_logic;
		data22_clk_o : out std_logic;
		data22_rst_o : out std_logic;
		data22_eof_o : out std_logic;
		data22_sof_o : out std_logic;
		data22_i_o : out std_logic_vector(DATA_SIZE-1 downto 0);
		data22_q_o : out std_logic_vector(DATA_SIZE-1 downto 0);
		data23_en_o : out std_logic;
		data23_clk_o : out std_logic;
		data23_rst_o : out std_logic;
		data23_eof_o : out std_logic;
		data23_sof_o : out std_logic;
		data23_i_o : out std_logic_vector(DATA_SIZE-1 downto 0);
		data23_q_o : out std_logic_vector(DATA_SIZE-1 downto 0);
		data24_en_o : out std_logic;
		data24_clk_o : out std_logic;
		data24_rst_o : out std_logic;
		data24_eof_o : out std_logic;
		data24_sof_o : out std_logic;
		data24_i_o : out std_logic_vector(DATA_SIZE-1 downto 0);
		data24_q_o : out std_logic_vector(DATA_SIZE-1 downto 0);
		data25_en_o : out std_logic;
		data25_clk_o : out std_logic;
		data25_rst_o : out std_logic;
		data25_eof_o : out std_logic;
		data25_sof_o : out std_logic;
		data25_i_o : out std_logic_vector(DATA_SIZE-1 downto 0);
		data25_q_o : out std_logic_vector(DATA_SIZE-1 downto 0);
		data26_en_o : out std_logic;
		data26_clk_o : out std_logic;
		data26_rst_o : out std_logic;
		data26_eof_o : out std_logic;
		data26_sof_o : out std_logic;
		data26_i_o : out std_logic_vector(DATA_SIZE-1 downto 0);
		data26_q_o : out std_logic_vector(DATA_SIZE-1 downto 0);
		data27_en_o : out std_logic;
		data27_clk_o : out std_logic;
		data27_rst_o : out std_logic;
		data27_eof_o : out std_logic;
		data27_sof_o : out std_logic;
		data27_i_o : out std_logic_vector(DATA_SIZE-1 downto 0);
		data27_q_o : out std_logic_vector(DATA_SIZE-1 downto 0);
		data28_en_o : out std_logic;
		data28_clk_o : out std_logic;
		data28_rst_o : out std_logic;
		data28_eof_o : out std_logic;
		data28_sof_o : out std_logic;
		data28_i_o : out std_logic_vector(DATA_SIZE-1 downto 0);
		data28_q_o : out std_logic_vector(DATA_SIZE-1 downto 0);
		data29_en_o : out std_logic;
		data29_clk_o : out std_logic;
		data29_rst_o : out std_logic;
		data29_eof_o : out std_logic;
		data29_sof_o : out std_logic;
		data29_i_o : out std_logic_vector(DATA_SIZE-1 downto 0);
		data29_q_o : out std_logic_vector(DATA_SIZE-1 downto 0);
		data30_en_o : out std_logic;
		data30_clk_o : out std_logic;
		data30_rst_o : out std_logic;
		data30_eof_o : out std_logic;
		data30_sof_o : out std_logic;
		data30_i_o : out std_logic_vector(DATA_SIZE-1 downto 0);
		data30_q_o : out std_logic_vector(DATA_SIZE-1 downto 0);
		data31_en_o : out std_logic;
		data31_clk_o : out std_logic;
		data31_rst_o : out std_logic;
		data31_eof_o : out std_logic;
		data31_sof_o : out std_logic;
		data31_i_o : out std_logic_vector(DATA_SIZE-1 downto 0);
		data31_q_o : out std_logic_vector(DATA_SIZE-1 downto 0);
		data32_en_o : out std_logic;
		data32_clk_o : out std_logic;
		data32_rst_o : out std_logic;
		data32_eof_o : out std_logic;
		data32_sof_o : out std_logic;
		data32_i_o : out std_logic_vector(DATA_SIZE-1 downto 0);
		data32_q_o : out std_logic_vector(DATA_SIZE-1 downto 0)
);
end dupplComplex;
architecture Behavioral of dupplComplex is
begin
	data1_i_o <= data_i_i;
	data1_q_o <= data_q_i;
	data1_en_o <= data_en_i;
	data1_clk_o <= data_clk_i;
	data1_rst_o <= data_rst_i;
	data1_eof_o <= data_eof_i;
	data1_sof_o <= data_sof_i;

	out2 : if NB_OUTPUT > 1 generate
		data2_i_o <= data_i_i;
		data2_q_o <= data_q_i;
		data2_en_o <= data_en_i;
		data2_clk_o <= data_clk_i;
		data2_rst_o <= data_rst_i;
		data2_eof_o <= data_eof_i;
		data2_sof_o <= data_sof_i;
	end generate out2;

	out3 : if NB_OUTPUT > 2 generate
		data3_i_o <= data_i_i;
		data3_q_o <= data_q_i;
		data3_en_o <= data_en_i;
		data3_clk_o <= data_clk_i;
		data3_rst_o <= data_rst_i;
		data3_eof_o <= data_eof_i;
		data3_sof_o <= data_sof_i;
	end generate out3;

	out4 : if NB_OUTPUT > 3 generate
		data4_i_o <= data_i_i;
		data4_q_o <= data_q_i;
		data4_en_o <= data_en_i;
		data4_clk_o <= data_clk_i;
		data4_rst_o <= data_rst_i;
		data4_eof_o <= data_eof_i;
		data4_sof_o <= data_sof_i;
	end generate out4;

	out5 : if NB_OUTPUT > 4 generate
		data5_i_o <= data_i_i;
		data5_q_o <= data_q_i;
		data5_en_o <= data_en_i;
		data5_clk_o <= data_clk_i;
		data5_rst_o <= data_rst_i;
		data5_eof_o <= data_eof_i;
		data5_sof_o <= data_sof_i;
	end generate out5;

	out6 : if NB_OUTPUT > 5 generate
		data6_i_o <= data_i_i;
		data6_q_o <= data_q_i;
		data6_en_o <= data_en_i;
		data6_clk_o <= data_clk_i;
		data6_rst_o <= data_rst_i;
		data6_eof_o <= data_eof_i;
		data6_sof_o <= data_sof_i;
	end generate out6;

	out7 : if NB_OUTPUT > 6 generate
		data7_i_o <= data_i_i;
		data7_q_o <= data_q_i;
		data7_en_o <= data_en_i;
		data7_clk_o <= data_clk_i;
		data7_rst_o <= data_rst_i;
		data7_eof_o <= data_eof_i;
		data7_sof_o <= data_sof_i;
	end generate out7;

	out8 : if NB_OUTPUT > 7 generate
		data8_i_o <= data_i_i;
		data8_q_o <= data_q_i;
		data8_en_o <= data_en_i;
		data8_clk_o <= data_clk_i;
		data8_rst_o <= data_rst_i;
		data8_eof_o <= data_eof_i;
		data8_sof_o <= data_sof_i;
	end generate out8;

	out9 : if NB_OUTPUT > 8 generate
		data9_i_o <= data_i_i;
		data9_q_o <= data_q_i;
		data9_en_o <= data_en_i;
		data9_clk_o <= data_clk_i;
		data9_rst_o <= data_rst_i;
		data9_eof_o <= data_eof_i;
		data9_sof_o <= data_sof_i;
	end generate out9;

	out10 : if NB_OUTPUT > 9 generate
		data10_i_o <= data_i_i;
		data10_q_o <= data_q_i;
		data10_en_o <= data_en_i;
		data10_clk_o <= data_clk_i;
		data10_rst_o <= data_rst_i;
		data10_eof_o <= data_eof_i;
		data10_sof_o <= data_sof_i;
	end generate out10;

	out11 : if NB_OUTPUT > 10 generate
		data11_i_o <= data_i_i;
		data11_q_o <= data_q_i;
		data11_en_o <= data_en_i;
		data11_clk_o <= data_clk_i;
		data11_rst_o <= data_rst_i;
		data11_eof_o <= data_eof_i;
		data11_sof_o <= data_sof_i;
	end generate out11;

	out12 : if NB_OUTPUT > 11 generate
		data12_i_o <= data_i_i;
		data12_q_o <= data_q_i;
		data12_en_o <= data_en_i;
		data12_clk_o <= data_clk_i;
		data12_rst_o <= data_rst_i;
		data12_eof_o <= data_eof_i;
		data12_sof_o <= data_sof_i;
	end generate out12;

	out13 : if NB_OUTPUT > 12 generate
		data13_i_o <= data_i_i;
		data13_q_o <= data_q_i;
		data13_en_o <= data_en_i;
		data13_clk_o <= data_clk_i;
		data13_rst_o <= data_rst_i;
		data13_eof_o <= data_eof_i;
		data13_sof_o <= data_sof_i;
	end generate out13;

	out14 : if NB_OUTPUT > 13 generate
		data14_i_o <= data_i_i;
		data14_q_o <= data_q_i;
		data14_en_o <= data_en_i;
		data14_clk_o <= data_clk_i;
		data14_rst_o <= data_rst_i;
		data14_eof_o <= data_eof_i;
		data14_sof_o <= data_sof_i;
	end generate out14;

	out15 : if NB_OUTPUT > 14 generate
		data15_i_o <= data_i_i;
		data15_q_o <= data_q_i;
		data15_en_o <= data_en_i;
		data15_clk_o <= data_clk_i;
		data15_rst_o <= data_rst_i;
		data15_eof_o <= data_eof_i;
		data15_sof_o <= data_sof_i;
	end generate out15;

	out16 : if NB_OUTPUT > 15 generate
		data16_i_o <= data_i_i;
		data16_q_o <= data_q_i;
		data16_en_o <= data_en_i;
		data16_clk_o <= data_clk_i;
		data16_rst_o <= data_rst_i;
		data16_eof_o <= data_eof_i;
		data16_sof_o <= data_sof_i;
	end generate out16;

	out17 : if NB_OUTPUT > 16 generate
		data17_i_o <= data_i_i;
		data17_q_o <= data_q_i;
		data17_en_o <= data_en_i;
		data17_clk_o <= data_clk_i;
		data17_rst_o <= data_rst_i;
		data17_eof_o <= data_eof_i;
		data17_sof_o <= data_sof_i;
	end generate out17;

	out18 : if NB_OUTPUT > 17 generate
		data18_i_o <= data_i_i;
		data18_q_o <= data_q_i;
		data18_en_o <= data_en_i;
		data18_clk_o <= data_clk_i;
		data18_rst_o <= data_rst_i;
		data18_eof_o <= data_eof_i;
		data18_sof_o <= data_sof_i;
	end generate out18;

	out19 : if NB_OUTPUT > 18 generate
		data19_i_o <= data_i_i;
		data19_q_o <= data_q_i;
		data19_en_o <= data_en_i;
		data19_clk_o <= data_clk_i;
		data19_rst_o <= data_rst_i;
		data19_eof_o <= data_eof_i;
		data19_sof_o <= data_sof_i;
	end generate out19;

	out20 : if NB_OUTPUT > 19 generate
		data20_i_o <= data_i_i;
		data20_q_o <= data_q_i;
		data20_en_o <= data_en_i;
		data20_clk_o <= data_clk_i;
		data20_rst_o <= data_rst_i;
		data20_eof_o <= data_eof_i;
		data20_sof_o <= data_sof_i;
	end generate out20;

	out21 : if NB_OUTPUT > 20 generate
		data21_i_o <= data_i_i;
		data21_q_o <= data_q_i;
		data21_en_o <= data_en_i;
		data21_clk_o <= data_clk_i;
		data21_rst_o <= data_rst_i;
		data21_eof_o <= data_eof_i;
		data21_sof_o <= data_sof_i;
	end generate out21;

	out22 : if NB_OUTPUT > 21 generate
		data22_i_o <= data_i_i;
		data22_q_o <= data_q_i;
		data22_en_o <= data_en_i;
		data22_clk_o <= data_clk_i;
		data22_rst_o <= data_rst_i;
		data22_eof_o <= data_eof_i;
		data22_sof_o <= data_sof_i;
	end generate out22;

	out23 : if NB_OUTPUT > 22 generate
		data23_i_o <= data_i_i;
		data23_q_o <= data_q_i;
		data23_en_o <= data_en_i;
		data23_clk_o <= data_clk_i;
		data23_rst_o <= data_rst_i;
		data23_eof_o <= data_eof_i;
		data23_sof_o <= data_sof_i;
	end generate out23;

	out24 : if NB_OUTPUT > 23 generate
		data24_i_o <= data_i_i;
		data24_q_o <= data_q_i;
		data24_en_o <= data_en_i;
		data24_clk_o <= data_clk_i;
		data24_rst_o <= data_rst_i;
		data24_eof_o <= data_eof_i;
		data24_sof_o <= data_sof_i;
	end generate out24;

	out25 : if NB_OUTPUT > 24 generate
		data25_i_o <= data_i_i;
		data25_q_o <= data_q_i;
		data25_en_o <= data_en_i;
		data25_clk_o <= data_clk_i;
		data25_rst_o <= data_rst_i;
		data25_eof_o <= data_eof_i;
		data25_sof_o <= data_sof_i;
	end generate out25;

	out26 : if NB_OUTPUT > 25 generate
		data26_i_o <= data_i_i;
		data26_q_o <= data_q_i;
		data26_en_o <= data_en_i;
		data26_clk_o <= data_clk_i;
		data26_rst_o <= data_rst_i;
		data26_eof_o <= data_eof_i;
		data26_sof_o <= data_sof_i;
	end generate out26;

	out27 : if NB_OUTPUT > 26 generate
		data27_i_o <= data_i_i;
		data27_q_o <= data_q_i;
		data27_en_o <= data_en_i;
		data27_clk_o <= data_clk_i;
		data27_rst_o <= data_rst_i;
		data27_eof_o <= data_eof_i;
		data27_sof_o <= data_sof_i;
	end generate out27;

	out28 : if NB_OUTPUT > 27 generate
		data28_i_o <= data_i_i;
		data28_q_o <= data_q_i;
		data28_en_o <= data_en_i;
		data28_clk_o <= data_clk_i;
		data28_rst_o <= data_rst_i;
		data28_eof_o <= data_eof_i;
		data28_sof_o <= data_sof_i;
	end generate out28;

	out29 : if NB_OUTPUT > 28 generate
		data29_i_o <= data_i_i;
		data29_q_o <= data_q_i;
		data29_en_o <= data_en_i;
		data29_clk_o <= data_clk_i;
		data29_rst_o <= data_rst_i;
		data29_eof_o <= data_eof_i;
		data29_sof_o <= data_sof_i;
	end generate out29;

	out30 : if NB_OUTPUT > 29 generate
		data30_i_o <= data_i_i;
		data30_q_o <= data_q_i;
		data30_en_o <= data_en_i;
		data30_clk_o <= data_clk_i;
		data30_rst_o <= data_rst_i;
		data30_eof_o <= data_eof_i;
		data30_sof_o <= data_sof_i;
	end generate out30;

	out31 : if NB_OUTPUT > 30 generate
		data31_i_o <= data_i_i;
		data31_q_o <= data_q_i;
		data31_en_o <= data_en_i;
		data31_clk_o <= data_clk_i;
		data31_rst_o <= data_rst_i;
		data31_eof_o <= data_eof_i;
		data31_sof_o <= data_sof_i;
	end generate out31;

	out32 : if NB_OUTPUT > 31 generate
		data32_i_o <= data_i_i;
		data32_q_o <= data_q_i;
		data32_en_o <= data_en_i;
		data32_clk_o <= data_clk_i;
		data32_rst_o <= data_rst_i;
		data32_eof_o <= data_eof_i;
		data32_sof_o <= data_sof_i;
	end generate out32;

end Behavioral;
