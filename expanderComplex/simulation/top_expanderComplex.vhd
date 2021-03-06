library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

entity top_expandercomplex is
	port (
		clk_i : in std_logic;
		rst_i : in std_logic;
		-- in
		data_en_i : in std_logic;
		data_i_i  : in std_logic_vector(15 downto 0);
		data_q_i  : in std_logic_vector(15 downto 0);
		-- out
		data_i_o  : out std_logic_vector(7 downto 0);
		data_q_o  : out std_logic_vector(7 downto 0);
		data_en_o : out std_logic
	);
end top_expandercomplex;

architecture Behavioral of top_expandercomplex is
begin
	shift_same_inst : entity work.expanderComplex
	generic map (
		format => "signed",
		DATA_IN_SIZE => 16,
		DATA_OUT_SIZE => 8 
	)
	port map (
		data_i_i => data_i_i, data_q_i => data_q_i, data_en_i => data_en_i,
		data_eof_i => '0', data_sof_i => '0',
		data_clk_i => clk_i, data_rst_i => rst_i,
		data_i_o => data_i_o, data_q_o => data_q_o, data_en_o => data_en_o,
		data_eof_o => open, data_sof_o => open,
		data_clk_o => open, data_rst_o => open
	);

end Behavioral;
