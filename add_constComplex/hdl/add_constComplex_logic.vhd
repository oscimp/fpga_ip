library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

Entity add_constComplex_logic is 
	generic (
		format : string := "signed";
		DATA_OUT_SIZE: natural := 18;
		DATA_IN_SIZE : natural := 16
	);
	port 
	(
		-- Syscon signals
		rst_i	: in std_logic;
		clk_i	: in std_logic;
		-- config
		add_val : in std_logic_vector(DATA_IN_SIZE-1 downto 0);
		-- input data
		data_i_i		: in std_logic_vector(DATA_IN_SIZE-1 downto 0);
		data_q_i		: in std_logic_vector(DATA_IN_SIZE-1 downto 0);
		data_en_i		: in std_logic;
		-- for the next component
		data_q_o		: out std_logic_vector(DATA_OUT_SIZE-1 downto 0);		
		data_i_o		: out std_logic_vector(DATA_OUT_SIZE-1 downto 0);		
		data_en_o		: out std_logic
	);
end entity;
Architecture bhv of add_constComplex_logic is
	signal data_in_i_s, data_i_s : std_logic_vector(DATA_OUT_SIZE-1 downto 0);
	signal data_in_resize_s : std_logic_vector(DATA_IN_SIZE-1 downto 0);
	signal add_val_s,add_val2_s : std_logic_vector(DATA_IN_SIZE-1 downto 0);
begin
    data_in_resize_s <= data_i;

	process(clk_i) begin
		if rising_edge(clk_i) then
			add_val_s <= add_val;
			add_val2_s <= add_val_s;
		end if;
	end process;
	
	signed_op: if format = "signed" generate
		data_in_i_s <= std_logic_vector(signed(data_i_i) 
				+ signed(add_val2_s));
		data_in_q_s <= std_logic_vector(signed(data_q_i) 
				+ signed(add_val2_s));
	end generate signed_op;
	unsigned_op: if format /= "signed" generate
		data_in_i_s <= std_logic_vector(signed(data_i_i) 
				+ signed(add_val2_s));
		data_in_q_s <= std_logic_vector(signed(data_q_i) 
				+ signed(add_val2_s));
	end generate unsigned_op;

	data_i_o <= data_i_s(DATA_OUT_SIZE-1 downto 0);
	data_q_o <= data_q_s(DATA_OUT_SIZE-1 downto 0);

	process(clk_i)
	begin
		if rising_edge(clk_i) then
			if rst_i = '1' then
				data_i_s <= (others => '0');
				data_q_s <= (others => '0');
				data_en_o <= '0';
			else
				data_i_s <= data_i_s;
				data_q_s <= data_q_s;
				data_en_o <= '0';
				if data_en_i = '1' then
					data_i_s <= data_in_i_s;
					data_q_s <= data_in_q_s;
					data_en_o <= '1';
				end if;
			end if;
		end if;
	end process;

end architecture bhv;

