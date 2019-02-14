library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

entity cvb_logic is
	generic (
		ACCUM_SIZE : natural := 32;
		DATA_SIZE : natural := 32;
		ADDR_SIZE : natural := 8
	);
	port (
		clk_i : in std_logic;
		reset : in std_logic;
		-- input
		data_en_i : in std_logic;
		data_eof_i : in std_logic;
		data_i_i : in std_logic_vector(DATA_SIZE-1 downto 0);
		data_q_i : in std_logic_vector(DATA_SIZE-1 downto 0);
		-- output
		data_en_o : out std_logic;
		data_eof_o : out std_logic;
		data_i_o : out std_logic_vector(DATA_SIZE-1 downto 0);
		data_q_o : out std_logic_vector(DATA_SIZE-1 downto 0);
		-- config from CPU
		start_mean_offset_i : in std_logic_vector(ADDR_SIZE-1 downto 0);
		max_allowed_val_i : in std_logic_vector(ACCUM_SIZE-1 downto 0);
		cpt_max_i : in std_logic_vector(ADDR_SIZE-1 downto 0)
	);
end cvb_logic;

architecture Behavioral of cvb_logic is
	-- cpt
	signal data_en_s : std_logic;
	signal data_eof_s : std_logic;
	signal w_addr_s : std_logic_vector(ADDR_SIZE-1 downto 0);

	-- check
	signal frame_valid_s : std_logic;


	-- dual ram
	signal w_data_s : std_logic_vector((DATA_SIZE*2)-1 downto 0);
	signal r_data_s : std_logic_vector((DATA_SIZE*2)-1 downto 0);
	-- gen flow
	signal data_eof_out_s : std_logic;
	signal r_data_i_s, r_data_q_s : std_logic_vector(DATA_SIZE-1 downto 0);
	signal r_addr_s : std_logic_vector(ADDR_SIZE-1 downto 0);
begin
	-- 
	cpt_en : entity work.cvb_cpt_en
	generic map (ADDR => ADDR_SIZE, DATA => DATA_SIZE)
	port map (clk_i => clk_i, rst_i => reset,
		data_en_i => data_en_i, data_eof_i => data_eof_i,
		data_en_o => data_en_s, data_eof_o => data_eof_s,
		data_addr_o => w_addr_s
	);

	-- check if input frame respect condition
	check_mean : entity work.cvb_check_mean
	generic map (ADDR => ADDR_SIZE, DATA => DATA_SIZE, ACCUM_SIZE => ACCUM_SIZE)
	port map (clk_i => clk_i, rst_i => reset,
		start_mean_offset_i => start_mean_offset_i,
		max_allowed_val_i => max_allowed_val_i,
		data_en_i => data_en_s, data_addr_i => w_addr_s,
		data_i_i => data_i_i, data_q_i => data_q_i, data_eof_i => data_eof_s,
		frame_valid_o => frame_valid_s
	);


	-- dual ram => one on write mode and one on read mode
	w_data_s <= data_i_i & data_q_i;

	dual_ram : entity work.cvb_dual_ram
	generic map (ADDR => ADDR_SIZE, DATA => 2 * DATA_SIZE)
	port map (clk_i => clk_i, rst_i => reset,
		w_switch_i => frame_valid_s,
		w_en_i => data_en_s, w_addr_i => w_addr_s, w_din_i => w_data_s,
		r_switch_i => data_eof_out_s, r_addr_i => r_addr_s, r_dout_o => r_data_s
	);

	r_data_i_s <= r_data_s((DATA_SIZE*2)-1 downto DATA_SIZE);
	r_data_q_s <= r_data_s(DATA_SIZE-1 downto 0);

	-- regen a data flow

	gen_new_flow : entity work.cvb_gen_new_flow
	generic map (ADDR => ADDR_SIZE, DATA => DATA_SIZE)
	port map (clk_i => clk_i, rst_i => reset,
		cpt_max_i => cpt_max_i, start_i => frame_valid_s,
		ram_i_i => r_data_i_s, ram_q_i => r_data_q_s,
		ram_addr_o => r_addr_s,
		data_i_o => data_i_o, data_q_o => data_q_o,
		data_eof_o => data_eof_out_s, data_en_o => data_en_o
	);

	data_eof_o <= data_eof_out_s;

end Behavioral;

