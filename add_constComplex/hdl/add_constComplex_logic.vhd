library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

Entity add_constComplex_logic is 
	generic (
		format : string := "signed";
		DATA_OUT_SIZE: natural := 18;
		DATA_IN_SIZE : natural := 16
	);
	port (
		-- Syscon signals
		rst_i     : in std_logic;
		clk_i     : in std_logic;
		-- config
		add_val   : in std_logic_vector(DATA_IN_SIZE-1 downto 0);
		-- input data
		data_i_i  : in std_logic_vector(DATA_IN_SIZE-1 downto 0);
		data_q_i  : in std_logic_vector(DATA_IN_SIZE-1 downto 0);
		data_en_i : in std_logic;
		-- for the next component
		data_q_o  : out std_logic_vector(DATA_OUT_SIZE-1 downto 0);
		data_i_o  : out std_logic_vector(DATA_OUT_SIZE-1 downto 0);
		data_en_o : out std_logic
	);
end entity;
Architecture bhv of add_constComplex_logic is
	signal data_res_i_s, data_res_q_s : std_logic_vector(DATA_IN_SIZE downto 0);
	signal data_add_i_s, data_add_q_s : std_logic_vector(DATA_IN_SIZE downto 0);
begin

	signed_op: if format = "signed" generate
		data_add_i_s <= std_logic_vector(resize(signed(data_i_i), DATA_IN_SIZE+1)
				+ resize(signed(add_val), DATA_IN_SIZE + 1));
		data_add_q_s <= std_logic_vector(resize(signed(data_q_i), DATA_IN_SIZE+1)
				+ resize(signed(add_val), DATA_IN_SIZE + 1));
		data_i_o <= std_logic_vector(resize(signed(data_res_i_s), DATA_OUT_SIZE));
		data_q_o <= std_logic_vector(resize(signed(data_res_q_s), DATA_OUT_SIZE));
	end generate signed_op;
	unsigned_op: if format /= "signed" generate
		data_add_i_s <= std_logic_vector(resize(unsigned(data_i_i), DATA_IN_SIZE+1)
				+ resize(unsigned(add_val), DATA_IN_SIZE + 1));
		data_add_q_s <= std_logic_vector(resize(unsigned(data_q_i), DATA_IN_SIZE+1)
				+ resize(unsigned(add_val), DATA_IN_SIZE + 1));
		data_i_o <= std_logic_vector(resize(unsigned(data_res_i_s), DATA_OUT_SIZE));
		data_q_o <= std_logic_vector(resize(unsigned(data_res_q_s), DATA_OUT_SIZE));
	end generate unsigned_op;

	process(clk_i) begin
		if rising_edge(clk_i) then
			data_en_o <= data_en_i;
			if data_en_i = '1' then
				data_res_i_s <= data_add_i_s;
				data_res_q_s <= data_add_q_s;
			end if;
			if rst_i = '1' then
				data_res_i_s <= (others => '0');
				data_res_q_s <= (others => '0');
				data_en_o    <= '0';
			end if;
		end if;
	end process;
end architecture bhv;

