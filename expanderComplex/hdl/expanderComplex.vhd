-- @title Expander Complex
-- @file expanderComplex
-- @author Gwenhael Goavec-Merou <gwenhael.goavec-merou@trabucayre.com>
-- @version 1
-- @date 2017/05/27
-- @copyright OscillatorIMP Digital
-- @brief Resize data stream by adding or suppressing Most Significant Bits

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

Entity expanderComplex is 
	generic (
		format : string := "signed"; -- tell if stream is signed or unsigned
		DATA_IN_SIZE : natural := 16; -- size of the input data stream
		DATA_OUT_SIZE : natural := 16 -- size of the output data stream
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
Architecture bhv of expanderComplex is
	-- return static size or difference between input and output size
	-- if in_size > out_size
	function comp_unused_slice(in_size, out_size: natural) return natural is
	begin
		if (in_size > out_size) then
			return (in_size - out_size + 1);
		else
			return(1);
		end if;
	end function comp_unused_slice;
	-- size of the dropped part of input signal
	constant MSB_SIZE : natural := comp_unused_slice(DATA_IN_SIZE, DATA_OUT_SIZE);
	-- dropped part of the I input signal
	signal msb_i_s : std_logic_vector(MSB_SIZE-1 downto 0);
	-- dropped part of the Q input signal
	signal msb_q_s : std_logic_vector(MSB_SIZE-1 downto 0);
	-- check is high slice is fully 0 and 1
	signal is_zero_i, is_one_i, is_zero_q, is_one_q: boolean;
begin
	data_clk_o <= data_clk_i;
	data_eof_o <= data_eof_i;
	data_sof_o <= data_sof_i;
	data_rst_o <= data_rst_i;
	data_en_o <= data_en_i;

	-- when output is smaller than input
	-- output only LSB but check for overflow and saturate signal is required
	less_out_size: if DATA_IN_SIZE > DATA_OUT_SIZE generate
		msb_i_s   <= data_i_i(DATA_IN_SIZE-1 downto DATA_IN_SIZE-MSB_SIZE);
		is_zero_i <= msb_i_s = (MSB_SIZE-1 downto 0 => '0');
		is_one_i  <= msb_i_s = (MSB_SIZE-1 downto 0 => '1');
		check_sature_i: process(data_i_i, msb_i_s, is_zero_i, is_one_i) begin
			-- not overflow
			if is_one_i or is_zero_i then
				data_i_o <= data_i_i(DATA_OUT_SIZE-1 downto 0);
			-- negative oferlow
			elsif msb_i_s(MSB_SIZE-1) = '1' then
				data_i_o <= '1' & (DATA_OUT_SIZE-2 downto 0 => '0');
			-- positive oferlow
			else
				data_i_o <= '0' & (DATA_OUT_SIZE-2 downto 0 => '1');
			end if;
		end process check_sature_i;
		msb_q_s   <= data_q_i(DATA_IN_SIZE-1 downto DATA_IN_SIZE-MSB_SIZE);
		is_zero_q <= msb_q_s = (MSB_SIZE-1 downto 0 => '0');
		is_one_q  <= msb_q_s = (MSB_SIZE-1 downto 0 => '1');
		check_sature_q: process(data_q_i, msb_q_s, is_zero_q, is_one_q) begin
			-- not overflow
			if is_one_q or is_zero_q then
				data_q_o <= data_q_i(DATA_OUT_SIZE-1 downto 0);
			-- negative oferlow
			elsif msb_q_s(MSB_SIZE-1) = '1' then
				data_q_o <= '1' & (DATA_OUT_SIZE-2 downto 0 => '0');
			-- positive oferlow
			else
				data_q_o <= '0' & (DATA_OUT_SIZE-2 downto 0 => '1');
			end if;
		end process check_sature_q;
	end generate less_out_size;

	-- same size => nothing to do
	same_size_gen: if DATA_IN_SIZE = DATA_OUT_SIZE generate
		data_i_o <= data_i_i;
		data_q_o <= data_q_i;
	end generate same_size_gen;

	-- input size < output size : expand data with sign bit if signed format
	-- or by '0' if unsigned
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

end architecture bhv;
