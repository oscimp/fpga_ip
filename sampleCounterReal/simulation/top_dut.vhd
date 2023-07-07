library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

entity top_dut is
	generic (
		SAMPLE_COUNTER_SIZE : natural := 32;
		DATA_SIZE           : natural := 16
	);
	port (
		clk_i        : in  std_logic;
		rst_i        : in  std_logic;
		-- data stream
		data_i       : in  std_logic_vector(DATA_SIZE-1 downto 0);
		data_en_i    : in  std_logic;
		data_sof_i   : in  std_logic;
		data_eof_i   : in  std_logic;
		data_i_o     : out std_logic_vector(DATA_SIZE-1 downto 0);
		data_q_o     : out std_logic_vector(DATA_SIZE-1 downto 0);
		data_en_o    : out std_logic;
		data_sof_o   : out std_logic;
		data_eof_o   : out std_logic;
		-- sample counter
		counter_o    : out std_logic_vector(SAMPLE_COUNTER_SIZE-1 downto 0);
		counter_en_o : out std_logic

	);
end top_dut;

architecture Behavioral of top_dut is
begin
	dut : entity work.sampleCounterReal
	generic map (
		SAMPLE_COUNTER_SIZE => SAMPLE_COUNTER_SIZE,
		DATA_SIZE     => DATA_SIZE
	)
	port map (
		data_clk_i => clk_i, data_rst_i => rst_i,
		data_i_i => data_i, data_q_i => data_i, data_en_i => data_en_i,
		data_sof_i => data_sof_i, data_eof_i => data_eof_i,
		data_i_o => data_i_o, data_q_o => data_q_o,
		data_en_o => data_en_o, data_sof_o => data_sof_o, data_eof_o => data_eof_o,

		counter_o => counter_o, counter_en_o => counter_en_o,
		counter_clk_o => open, counter_rst_o => open,
		counter_sof_o => open, counter_eof_o => open
	);

end Behavioral;
