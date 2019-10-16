library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

entity top_shiftercomplex is
	port (
		clk_i : in std_logic;
		rst_i : in std_logic;
		-- in
		nco_en_i   : in std_logic;
		nco_i_i    : in std_logic_vector(15 downto 0);
		nco_q_i    : in std_logic_vector(15 downto 0);
		data_en_i : in std_logic;
		data_i_i  : in std_logic_vector(15 downto 0);
		data_q_i  : in std_logic_vector(15 downto 0);
		-- out
		data_lt_i_o  : out std_logic_vector(15 downto 0);
		data_lt_q_o  : out std_logic_vector(15 downto 0);
		data_lt_en_o : out std_logic;
		data_eq_i_o  : out std_logic_vector(31 downto 0);
		data_eq_q_o  : out std_logic_vector(31 downto 0);
		data_eq_en_o : out std_logic;
		data_gt_i_o  : out std_logic_vector(32 downto 0);
		data_gt_q_o  : out std_logic_vector(32 downto 0);
		data_gt_en_o : out std_logic
	);
end top_shiftercomplex;

architecture Behavioral of top_shiftercomplex is
begin
	-- internaly data are shift
	-- 16x16 -1 => 31 => 16
	lt_sz_inst : entity work.mixerComplex_sin
	generic map (
		NCO_SIZE => 16,
		DATA_IN_SIZE => 16,
		DATA_OUT_SIZE => 16 
	)
	port map (
		-- data
		data_i_i => data_i_i, data_q_i => data_q_i,
		data_en_i=> data_en_i,
		data_clk_i => clk_i, data_rst_i => rst_i,
		-- nco
		nco_i_i => nco_i_i, nco_q_i => nco_q_i,
		nco_en_i => nco_en_i, nco_clk_i => clk_i, nco_rst_i => rst_i,
		-- output
		data_i_o => data_lt_i_o, data_q_o => data_lt_q_o,
		data_en_o => data_lt_en_o, data_clk_o => open, data_rst_o => open
	);

	-- 16x16 -1 => 31 => 16
	eq_sz_inst : entity work.mixerComplex_sin
	generic map (
		NCO_SIZE => 16,
		DATA_IN_SIZE => 16,
		DATA_OUT_SIZE => 32 
	)
	port map (
		-- data
		data_i_i => data_i_i, data_q_i => data_q_i,
		data_en_i=> data_en_i,
		data_clk_i => clk_i, data_rst_i => rst_i,
		-- nco
		nco_i_i => nco_i_i, nco_q_i => nco_q_i,
		nco_en_i => nco_en_i, nco_clk_i => clk_i, nco_rst_i => rst_i,
		-- output
		data_i_o => data_eq_i_o, data_q_o => data_eq_q_o,
		data_en_o => data_eq_en_o, data_clk_o => open, data_rst_o => open
	);
	-- 16x16 -1 => 31 => 16
	gt_sz_inst : entity work.mixerComplex_sin
	generic map (
		NCO_SIZE => 16,
		DATA_IN_SIZE => 16,
		DATA_OUT_SIZE => 33 
	)
	port map (
		-- data
		data_i_i => data_i_i, data_q_i => data_q_i,
		data_en_i=> data_en_i,
		data_clk_i => clk_i, data_rst_i => rst_i,
		-- nco
		nco_i_i => nco_i_i, nco_q_i => nco_q_i,
		nco_en_i => nco_en_i, nco_clk_i => clk_i, nco_rst_i => rst_i,
		-- output
		data_i_o => data_gt_i_o, data_q_o => data_gt_q_o,
		data_en_o => data_gt_en_o, data_clk_o => open, data_rst_o => open
	);
end Behavioral;
