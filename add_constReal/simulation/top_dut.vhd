library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

entity top_dut is
	port (
		i_clk : in std_logic;
		i_rst : in std_logic;

		-- signed intance
		i_add_val_signed   : in  std_logic_vector(7 downto 0);
		i_data_signed      : in  std_logic_vector(7 downto 0);
		i_data_en_signed   : in  std_logic;
		o_data_signed      : out std_logic_vector(8 downto 0);
		o_data_en_signed   : out std_logic;
		-- unsigned intance
		i_add_val_unsigned : in  std_logic_vector(7 downto 0);
		i_data_unsigned    : in  std_logic_vector(7 downto 0);
		i_data_en_unsigned : in  std_logic;
		o_data_unsigned    : out std_logic_vector(8 downto 0);
		o_data_en_unsigned : out std_logic
	);
end entity top_dut;
Architecture bhv of top_dut is
begin
	add_constReal_signed: entity work.add_constReal_logic
	generic map(
		format => "signed",
		DATA_IN_SIZE => 8,
		DATA_OUT_SIZE => 9
	)
	port map (
		rst_i => i_rst, clk_i => i_clk,
		add_val => i_add_val_signed,
		data_i => i_data_signed, data_en_i => i_data_en_signed,
		data_o => o_data_signed, data_en_o => o_data_en_signed
	);

	add_constReal_unsigned: entity work.add_constReal_logic
	generic map(
		format => "unsigned",
		DATA_IN_SIZE => 8,
		DATA_OUT_SIZE => 9
	)
	port map (
		rst_i => i_rst, clk_i => i_clk,
		add_val => i_add_val_unsigned,
		data_i => i_data_unsigned, data_en_i => i_data_en_unsigned,
		data_o => o_data_unsigned, data_en_o => o_data_en_unsigned
	);
end architecture bhv;
