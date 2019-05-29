---------------------------------------------------------------------------
-- (c) Copyright: OscillatorIMP Digital
-- Author : Gwenhael Goavec-Merou<gwenhael.goavec-merou@trabucayre.com>
-- Creation date : 2017/05/27
---------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

Entity expanderComplex is 
	generic (
		format : string := "signed";
		DATA_IN_SIZE : natural := 16;
		DATA_OUT_SIZE : natural := 16
	);
	port (
		-- input data
		data_i_i			: in std_logic_vector(DATA_IN_SIZE-1 downto 0);
		data_q_i			: in std_logic_vector(DATA_IN_SIZE-1 downto 0);
		data_en_i			: in std_logic;
		data_sof_i			: in std_logic;
		data_eof_i			: in std_logic;
		data_rst_i			: in std_logic;
		data_clk_i			: in std_logic;
		-- for the next component
		data_i_o			: out std_logic_vector(DATA_OUT_SIZE-1 downto 0);		
		data_q_o			: out std_logic_vector(DATA_OUT_SIZE-1 downto 0);		
		data_en_o			: out std_logic;
		data_sof_o			: out std_logic;
		data_eof_o			: out std_logic;
		data_rst_o			: out std_logic;
		data_clk_o			: out std_logic
	);
end entity;
Architecture expanderComplex_1 of expanderComplex is
begin
	data_clk_o <= data_clk_i;
	data_eof_o <= data_eof_i;
	data_sof_o <= data_sof_i;
	data_rst_o <= data_rst_i;
	data_en_o <= data_en_i;

	less_out_size: if DATA_IN_SIZE > DATA_OUT_SIZE generate
		data_i_o <= data_i_i(DATA_OUT_SIZE-1 downto 0);
		data_q_o <= data_q_i(DATA_OUT_SIZE-1 downto 0);
	end generate less_out_size;

	same_size_gen: if DATA_IN_SIZE = DATA_OUT_SIZE generate
		data_i_o <= data_i_i;
		data_q_o <= data_q_i;
	end generate same_size_gen;

	diff_size_gen: if DATA_IN_SIZE < DATA_OUT_SIZE generate
		signed_data: if format = "signed" generate
			data_i_o <= 
				(DATA_OUT_SIZE-1 downto DATA_IN_SIZE => data_i_i(DATA_IN_SIZE-1)) &
				data_i_i;
			data_q_o <= 
				(DATA_OUT_SIZE-1 downto DATA_IN_SIZE => data_q_i(DATA_IN_SIZE-1)) &
				data_q_i;
		end generate signed_data;
		unsigned_data: if format /= "signed" generate
			data_i_o <= 
				(DATA_OUT_SIZE-1 downto DATA_IN_SIZE => '0') & data_i_i;
			data_q_o <= 
				(DATA_OUT_SIZE-1 downto DATA_IN_SIZE => '0') & data_q_i;
		end generate unsigned_data;
	end generate diff_size_gen;

end architecture expanderComplex_1;
