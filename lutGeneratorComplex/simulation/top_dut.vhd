library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

entity top_dut is
	port (
		clk_i        : in std_logic;
		rst_i        : in std_logic;
		-- cfg
		prescaler_i  : in std_logic_vector(11 downto 0);
		enable_i     : in std_logic;
		ram_length_i : in std_logic_vector(9 downto 0);
		-- lut 
		data_en_i    : in std_logic;
		data_i_i     : in std_logic_vector(15 downto 0);
		data_q_i     : in std_logic_vector(15 downto 0);
		data_adr_i   : in std_logic_vector( 9 downto 0);
		-- out
		data_i_o     : out std_logic_vector(15 downto 0);
		data_q_o     : out std_logic_vector(15 downto 0);
		data_en_o    : out std_logic
	);
end top_dut;

architecture Behavioral of top_dut is
begin
	dut : entity work.lutGeneratorComplex_logic
	generic map (
		PRESC_SIZE => 12,
		ADDR_SIZE  => 10,
		DATA_SIZE  => 16
	)
	port map (
		cpu_clk => clk_i, clk => clk_i, reset => rst_i,
		data_i_i => data_i_i, data_en_i_i => data_en_i, data_adr_i_i => data_adr_i,
		data_q_i => data_q_i, data_en_q_i => data_en_i, data_adr_q_i => data_adr_i,
		prescaler_i => prescaler_i, enable_i => enable_i, ram_length_i => ram_length_i,
		data_i_o => data_i_o, data_q_o => data_q_o, data_en_o => data_en_o,
		data_eof_o => open
	);

end Behavioral;
