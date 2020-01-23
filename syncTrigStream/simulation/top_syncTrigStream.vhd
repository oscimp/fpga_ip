library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

entity top_genpulsetwowaycplx is
	port (
		clk_i : in std_logic;
		rst_i : in std_logic;
		-- pulse
		pulse_o : out std_logic;
		-- config
		duty_cnt_i   : in std_logic_vector(31 downto 0);
		period_cnt_i : in std_logic_vector(31 downto 0);
		-- in
		data_en_i    : in std_logic;
		data1_i_i    : in std_logic_vector(15 downto 0);
		data1_q_i    : in std_logic_vector(15 downto 0);
		data2_i_i    : in std_logic_vector(15 downto 0);
		data2_q_i    : in std_logic_vector(15 downto 0);

		data_en_o    : out std_logic;
		data1_i_o    : out std_logic_vector(15 downto 0);
		data1_q_o    : out std_logic_vector(15 downto 0);
		data2_i_o    : out std_logic_vector(15 downto 0);
		data2_q_o    : out std_logic_vector(15 downto 0);
		data_sof_o   : out std_logic;
		data_eof_o   : out std_logic
	);
end top_genpulsetwowaycplx;

architecture Behavioral of top_genpulsetwowaycplx is
begin
	-- internaly data are shift
	-- 16x16 -1 => 31 => 16
	lt_sz_inst : entity work.syncTrigStream_logic
	generic map (
		GEN_SIZE => 32,
		DATA_SIZE => 16,
		NB_SAMPLE => 20 
	)
	port map (
		clk => clk_i, reset => rst_i,
		-- pulse
		pulse_o => pulse_o,
		-- config
		duty_cnt_i => duty_cnt_i, period_cnt_i => period_cnt_i,
		-- in data
		data_en_i => data_en_i,
		data1_i_i => data1_i_i, data1_q_i => data1_q_i,
		data2_i_i => data2_i_i, data2_q_i => data2_q_i,
		-- out data
		data1_i_o => data1_i_o, data1_q_o => data1_q_o,
		data2_i_o => data2_i_o, data2_q_o => data2_q_o,
		data_en_o => data_en_o, data_sof_o => data_sof_o,
		data_eof_o => data_eof_o
	);

end Behavioral;
