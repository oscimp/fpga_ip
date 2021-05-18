library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

Entity fft_loop_stage is 
	generic (
		USE_FIRST_BUFF : boolean := true;
		USE_SEC_BUFF : boolean := true;
		DEBUG : boolean := false;
		LOG_2_N_FFT : natural := 8;
		SHIFT_VAL : natural := 16;
		COEFF_SIZE : natural := 16;
		N_FFT : natural := 2048;
		ADDR_SIZE : natural := 10;
		DATA_SIZE : natural := 16
	);
	port 
	(
		-- Syscon signals
		clk_i		: in std_logic;
		cpu_clk_i	: in std_logic;
		rst_i		: in std_logic;
		-- control
		start_fft_i : in std_logic;
		done_fft_o : out std_logic;
		-- input data
		data_re_i  : in std_logic_vector(DATA_SIZE-1 downto 0);
		data_im_i  : in std_logic_vector(DATA_SIZE-1 downto 0);
		data_addr_i : in std_logic_vector(ADDR_SIZE-1 downto 0);
		data_en_i : in std_logic;


		--configuration
		read_coeff_re_o : out std_logic_vector(COEFF_SIZE-1 downto 0);
		read_coeff_im_o : out std_logic_vector(COEFF_SIZE-1 downto 0);
		coeff_re_i : in std_logic_vector(COEFF_SIZE-1 downto 0);
		coeff_re_addr_i : std_logic_vector(ADDR_SIZE-1 downto 0);
		coeff_re_en_i : std_logic;
		coeff_im_i : in std_logic_vector(COEFF_SIZE-1 downto 0);
		coeff_im_addr_i : std_logic_vector(ADDR_SIZE-1 downto 0);
		coeff_im_en_i : std_logic;
		res_re_o  : out std_logic_vector(DATA_SIZE-1 downto 0);
		res_im_o  : out std_logic_vector(DATA_SIZE-1 downto 0);
		res_addr_i : in std_logic_vector(ADDR_SIZE-1 downto 0)

	);
end entity;
Architecture fft_loop_stage_1 of fft_loop_stage is
	constant N_FFT_DIV_2 : std_logic_vector(ADDR_SIZE-1 downto 0) := 
		'1'&(ADDR_SIZE-2 downto 0 => '0');
	type state_type is (IDLE, WAIT_END_COMP);
	signal state_s, state_next_s : state_type;
	signal stage_s, stage_next_s : natural range 0 to LOG_2_N_FFT;
	signal n_of_b_s, n_of_b_next_s : std_logic_vector(ADDR_SIZE-1 downto 0);
	signal s_of_b_s, s_of_b_next_s : std_logic_vector(ADDR_SIZE-1 downto 0);
	signal start_radix_s, radix_done_s : std_logic;
	signal start_radix_next_s : std_logic;
	signal stage_slv_s : std_logic_vector(ADDR_SIZE-1 downto 0);
	--new
	signal done_fft_next_s : std_logic;
begin
	stage_slv_s <= std_logic_vector(to_unsigned(stage_s, ADDR_SIZE));

	process(clk_i)
	begin
		if rising_edge(clk_i) then
			if rst_i = '1' then
				state_s <= IDLE;
				n_of_b_s <= (others => '0');
				s_of_b_s <= (others => '0');
				start_radix_s <= '0';
				done_fft_o <= '0';
				stage_s <= 0;
			else
				state_s	<= state_next_s;
				n_of_b_s <= n_of_b_next_s;
				s_of_b_s <= s_of_b_next_s;
				start_radix_s <= start_radix_next_s;
				stage_s <= stage_next_s;
				done_fft_o <= done_fft_next_s;
			end if;
		end if;
	end process;

	process(state_s, n_of_b_s, s_of_b_s, stage_s,
			start_fft_i, radix_done_s)
	begin
		state_next_s  <= state_s;
		n_of_b_next_s <= n_of_b_s;
		s_of_b_next_s <= s_of_b_s;
		start_radix_next_s <= '0';
		stage_next_s <= stage_s;

		case state_s is
		when IDLE =>
			if start_fft_i = '1' then
				state_next_s <= WAIT_END_COMP;
				n_of_b_next_s <= N_FFT_DIV_2;
				s_of_b_next_s <= (ADDR_SIZE-1 downto 1 => '0') & '1';
				start_radix_next_s <= '1';
				stage_next_s <= 0;
			end if;
		when WAIT_END_COMP =>
			if radix_done_s = '1' then
				if stage_s < LOG_2_N_FFT-1 then
					n_of_b_next_s <= '0'&n_of_b_s(ADDR_SIZE-1 downto 1);
					s_of_b_next_s <= s_of_b_s(ADDR_SIZE-2 downto 0)&'0';
					stage_next_s <= stage_s + 1;
					start_radix_next_s <= '1';
				else
					state_next_s <= IDLE;
				end if;
			end if;
		end case;
	end process;

	process(radix_done_s, stage_s)
	begin
		done_fft_next_s <= '0';
		if radix_done_s = '1' then
			if stage_s = LOG_2_N_FFT-1 then
				done_fft_next_s <= '1';
			end if;
		end if;
	end process;

	fft_radix_inst : entity work.fft_loop_radix
	generic map (USE_FIRST_BUFF => USE_FIRST_BUFF, USE_SEC_BUFF => USE_SEC_BUFF,
		DEBUG => DEBUG,
		SHIFT_VAL => SHIFT_VAL, COEFF_SIZE => COEFF_SIZE,
		ADDR_SIZE => ADDR_SIZE, DATA_SIZE => DATA_SIZE)
	port map (clk_i => clk_i, cpu_clk_i => cpu_clk_i, rst_i => rst_i,
		-- test
		t_stage_i => stage_slv_s,
		-- control
		start_radix_i => start_radix_s, done_radix_o => radix_done_s,
		a_index_rst_i => start_fft_i,
		-- from previous stage
		n_of_b_i => n_of_b_s, s_of_b_i => s_of_b_s,
		-- input data
		data_re_i => data_re_i, data_im_i => data_im_i,
		data_addr_i => data_addr_i, data_en_i => data_en_i,
		-- configuration
		read_coeff_re_o => read_coeff_re_o, read_coeff_im_o => read_coeff_im_o,
		coeff_re_addr_i => coeff_re_addr_i, coeff_re_en_i => coeff_re_en_i,
		coeff_im_addr_i => coeff_im_addr_i, coeff_im_en_i => coeff_im_en_i,
		coeff_re_i => coeff_re_i, coeff_im_i => coeff_im_i,
		--results
		res_re_o => res_re_o, res_im_o => res_im_o, res_addr_i => res_addr_i);

end architecture fft_loop_stage_1;

