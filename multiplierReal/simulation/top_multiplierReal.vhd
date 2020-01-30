library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

entity top_multiplierreal is
	port (
		clk_i : in std_logic;
		rst_i : in std_logic;
		-- in
		data1_en_i   : in std_logic;
		data1_eof_i  : in std_logic;
		data1_sof_i  : in std_logic;
		data1_i      : in std_logic_vector(15 downto 0);
		data2_en_i   : in std_logic;
		data2_eof_i  : in std_logic;
		data2_sof_i  : in std_logic;
		data2_i      : in std_logic_vector(15 downto 0);
		data2_q_i    : in std_logic_vector(15 downto 0);
		-- out
		data_lt_o    : out std_logic_vector(15 downto 0);
		data_lt_en_o : out std_logic;
		data_eq_o    : out std_logic_vector(31 downto 0);
		data_eq_en_o : out std_logic;
		data_gt_o    : out std_logic_vector(32 downto 0);
		data_gt_en_o : out std_logic
	);
end top_multiplierreal;

architecture Behavioral of top_multiplierreal is
begin
	-- internaly data are shift
	-- 16x16 -1 => 31 => 16
	lt_sz_inst : entity work.multiplierReal
	generic map (
		SIGNED_FORMAT => true,
		DATA_IN_SIZE => 16,
		DATA_OUT_SIZE => 16 
	)
	port map (
		-- data
		data1_i => data1_i, data1_en_i=> data1_en_i,
		data1_eof_i => data1_eof_i, data1_sof_i => data1_sof_i,
		data1_clk_i => clk_i, data1_rst_i => rst_i,
		-- nco
		data2_i => data2_i, data2_en_i => data2_en_i,
		data2_eof_i => data2_eof_i, data2_sof_i => data2_sof_i,
		data2_clk_i => clk_i, data2_rst_i => rst_i,
		-- output
		data_o => data_lt_o,
		data_en_o => data_lt_en_o, data_clk_o => open, data_rst_o => open
	);

	-- 16x16 -1 => 31 => 16
	eq_sz_inst : entity work.multiplierReal
	generic map (
		SIGNED_FORMAT => true,
		DATA_IN_SIZE => 16,
		DATA_OUT_SIZE => 32 
	)
	port map (
		-- data
		data1_i => data1_i,
		data1_en_i=> data1_en_i,
		data1_eof_i => data1_eof_i, data1_sof_i => data1_sof_i,
		data1_clk_i => clk_i, data1_rst_i => rst_i,
		-- nco
		data2_i => data2_i, data2_en_i => data2_en_i,
		data2_eof_i => data2_eof_i, data2_sof_i => data2_sof_i,
		data2_clk_i => clk_i, data2_rst_i => rst_i,
		-- output
		data_o => data_eq_o,
		data_en_o => data_eq_en_o, data_clk_o => open, data_rst_o => open
	);
	-- 16x16 -1 => 31 => 16
	gt_sz_inst : entity work.multiplierReal
	generic map (
		SIGNED_FORMAT => true,
		DATA_IN_SIZE => 16,
		DATA_OUT_SIZE => 33 
	)
	port map (
		-- data
		data1_i => data1_i, data1_en_i=> data1_en_i,
		data1_eof_i => data1_eof_i, data1_sof_i => data1_sof_i,
		data1_clk_i => clk_i, data1_rst_i => rst_i,
		-- nco
		data2_i => data2_i, data2_en_i => data2_en_i,
		data2_eof_i => data2_eof_i, data2_sof_i => data2_sof_i,
		data2_clk_i => clk_i, data2_rst_i => rst_i,
		-- output
		data_o => data_gt_o,
		data_en_o => data_gt_en_o, data_clk_o => open, data_rst_o => open
	);
end Behavioral;
