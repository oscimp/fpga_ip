library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

Entity add_constReal_logic is
	generic (
		format : string := "signed";
		DATA_OUT_SIZE: natural := 18;
		DATA_IN_SIZE : natural := 16
	);
	port (
		-- Syscon signals
		rst_i           : in std_logic;
		clk_i           : in std_logic;
		-- config
		add_val         : in std_logic_vector(DATA_IN_SIZE-1 downto 0);
		-- input data
		data_i          : in std_logic_vector(DATA_IN_SIZE-1 downto 0);
		data_en_i       : in std_logic;
		-- for the next component
		data_o			: out std_logic_vector(DATA_OUT_SIZE-1 downto 0);		
		data_en_o		: out std_logic
	);
end entity;
Architecture bhv of add_constReal_logic is
	signal data_in_s, data_s : std_logic_vector(DATA_OUT_SIZE-1 downto 0);
begin

	signed_op: if format = "signed" generate
		data_in_s <= std_logic_vector(resize(signed(data_i), DATA_OUT_SIZE)
				+ resize(signed(add_val), DATA_OUT_SIZE));
	end generate signed_op;
	unsigned_op: if format /= "signed" generate
		data_in_s <= std_logic_vector(resize(unsigned(data_i), DATA_OUT_SIZE)
				+ resize(unsigned(add_val), DATA_OUT_SIZE));
	end generate unsigned_op;

	data_o <= data_s(DATA_OUT_SIZE-1 downto 0);

	process(clk_i)
	begin
		if rising_edge(clk_i) then
			if rst_i = '1' then
				data_en_o <= '0';
			elsif data_en_i = '1' then
				data_en_o <= '1';
			else
				data_en_o <= '0';
			end if;
			if rst_i = '1' then
				data_s <= (others => '0');
			elsif data_en_i = '1' then
				data_s <= data_in_s;
			else
				data_s <= data_s;
			end if;
		end if;
	end process;
end architecture bhv;

