---------------------------------------------------------------------------
-- (c) Copyright: OscillatorIMP Digital
-- Author : Gwenhael Goavec-Merou<gwenhael.goavec-merou@trabucayre.com>
-- Creation date : 2016/05/25
---------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

Entity sampleCounterComplex is 
	generic (
		SAMPLE_COUNTER_SIZE : natural := 32;
		DATA_SIZE           : natural := 16
	);
	port (
		-- input ref stream
		data_rst_i     : in  std_logic;
		data_clk_i     : in  std_logic;
		data_i_i       : in  std_logic_vector(DATA_SIZE-1 downto 0);
		data_q_i       : in  std_logic_vector(DATA_SIZE-1 downto 0);
		data_en_i      : in  std_logic := '0';
		data_sof_i     : in  std_logic := '0';
		data_eof_i     : in  std_logic := '0';
		-- input ref stream
		data_rst_o     : out std_logic;
		data_clk_o     : out std_logic;
		data_i_o       : out std_logic_vector(DATA_SIZE-1 downto 0);
		data_q_o       : out std_logic_vector(DATA_SIZE-1 downto 0);
		data_en_o      : out std_logic := '0';
		data_sof_o     : out std_logic := '0';
		data_eof_o     : out std_logic := '0';
		-- for the next component
		counter_rst_o  : out std_logic;
		counter_clk_o  : out std_logic;
		counter_o      : out std_logic_vector(SAMPLE_COUNTER_SIZE-1 downto 0) := (others => '0');
		counter_en_o   : out std_logic := '0';
		counter_eof_o  : out std_logic := '0';
		counter_sof_o  : out std_logic := '0'
	);
end entity;
Architecture bhv of sampleCounterComplex is
	signal sample_cnt_s      : unsigned(SAMPLE_COUNTER_SIZE-1 downto 0) := (others => '0');
	signal sample_cnt_next_s : unsigned(SAMPLE_COUNTER_SIZE-1 downto 0);

begin
	data_clk_o    <= data_clk_i;
	counter_clk_o <= data_clk_i;
	data_rst_o    <= data_rst_i;
	counter_rst_o <= data_rst_i;

	-- sample counter
	sample_cnt_next_s <= sample_cnt_s + 1;
	process(data_clk_i) begin
		if rising_edge(data_clk_i) then
			counter_en_o  <= '0';
			counter_sof_o <= '0';
			counter_eof_o <= '0';

			if data_en_i = '1' then
				sample_cnt_s  <= sample_cnt_next_s;
				counter_o     <= std_logic_vector(sample_cnt_s);
				counter_en_o  <= data_en_i;
				counter_eof_o <= data_eof_i;
				counter_sof_o <= data_sof_i;
			end if;
			if data_rst_i = '1' then
				sample_cnt_s  <= (SAMPLE_COUNTER_SIZE-1 downto 0 => '0');
				counter_o     <= (SAMPLE_COUNTER_SIZE-1 downto 0 => '0');
				counter_en_o  <= '0';
				counter_eof_o <= '0';
				counter_sof_o <= '0';
			end if;
		end if;
	end process;

	process(data_clk_i) begin
		if rising_edge(data_clk_i) then
			data_en_o  <= '0';
			data_sof_o <= '0';
			data_eof_o <= '0';

			if (data_en_i = '1') then
				data_i_o   <= data_i_i;
				data_q_o   <= data_q_i;
				data_en_o  <= data_en_i;
				data_sof_o <= data_sof_i;
				data_eof_o <= data_eof_i;
			end if;

			if data_rst_i = '1' then
				data_i_o   <= (others => '0');
				data_q_o   <= (others => '0');
				data_en_o  <= '0';
				data_sof_o <= '0';
				data_eof_o <= '0';
			end if;
		end if;
	end process;
end architecture bhv;
