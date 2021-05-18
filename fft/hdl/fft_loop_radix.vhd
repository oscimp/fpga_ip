library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

Entity fft_loop_radix is 
	generic (
		USE_FIRST_BUFF : boolean := true;
		USE_SEC_BUFF : boolean := true;
		DEBUG : boolean := false;
		SHIFT_VAL : natural := 16;
		COEFF_SIZE : natural := 16;
		LOG_2_N_FFT : natural := 8;
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
		-- test
		t_stage_i : in std_logic_vector(ADDR_SIZE-1 downto 0);
		-- control
		start_radix_i : in std_logic;
		done_radix_o : out std_logic;
		a_index_rst_i : in std_logic;

		-- from previous stage
		n_of_b_i : in std_logic_vector(ADDR_SIZE-1 downto 0);
		s_of_b_i : in std_logic_vector(ADDR_SIZE-1 downto 0);
		-- input data
		data_re_i  : in std_logic_vector(DATA_SIZE-1 downto 0);
		data_addr_i : in std_logic_vector(ADDR_SIZE-1 downto 0);
		data_en_i : in std_logic;
		data_im_i  : in std_logic_vector(DATA_SIZE-1 downto 0);
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
Architecture fft_loop_radix_1 of fft_loop_radix is
	signal N_FFT_MINUS_1 : std_logic_vector(ADDR_SIZE-1 downto 0) :=
	(ADDR_SIZE-1 downto 0 => '1');
	type state_type is (IDLE, WAIT_END_COMP);
	signal state_s : state_type;
	signal nb_index_s : natural range 0 to 2**ADDR_SIZE-1;
	signal start_but_s : std_logic;
	signal done_but_s : std_logic;
	signal a_index_s : std_logic_vector(ADDR_SIZE-1 downto 0);
	signal a_index_ref_s : std_logic_vector(ADDR_SIZE-1 downto 0);
	signal a_index_out_s : std_logic_vector(ADDR_SIZE-1 downto 0);
	signal n_of_b_nat_s : natural range 0 to 2**ADDR_SIZE;
	signal a2_index_s : std_logic_vector(ADDR_SIZE-1 downto 0);
	signal nb_index_slv_s : std_logic_vector(ADDR_SIZE-1 downto 0);

	-- new
	signal state_next_s : state_type;
	signal nb_index_next_s : natural range 0 to 2**ADDR_SIZE-1;
	signal start_but_next_s : std_logic;
	signal a_index_next_s : std_logic_vector(ADDR_SIZE-1 downto 0);
	signal a_index_ref_next_s : std_logic_vector(ADDR_SIZE-1 downto 0);
	signal done_radix_next_s : std_logic;
begin
	nb_index_slv_s <= std_logic_vector(to_unsigned(nb_index_s, ADDR_SIZE));

	n_of_b_nat_s <= to_integer(unsigned(n_of_b_i));

	a2_index_s <= std_logic_vector(
		unsigned(
			(s_of_b_i(ADDR_SIZE-2 downto 0)&'0')) + unsigned(a_index_out_s)) and
		N_FFT_MINUS_1;
	
	process(clk_i)
	begin
		if rising_edge(clk_i) then
			if rst_i = '1' then
				state_s <= IDLE;
				nb_index_s <= 0;
				start_but_s <= '0';
				a_index_s <= (others => '0');
				a_index_ref_s <= (others => '0');
				done_radix_o <= '0';
			else
				state_s	<= state_next_s;
				nb_index_s <= nb_index_next_s;
				start_but_s <= start_but_next_s;
				a_index_s <= a_index_next_s;
				a_index_ref_s <= a_index_ref_next_s;
				done_radix_o <= done_radix_next_s;
			end if;
		end if;
	end process;

	process(state_s, nb_index_s,
			start_radix_i, a_index_rst_i, done_but_s, a2_index_s,
			nb_index_s, n_of_b_nat_s)
	begin
		state_next_s <= state_s;
		nb_index_next_s <= nb_index_s;
		start_but_next_s <= '0';
		done_radix_next_s <= '0';

		case state_s is
		when IDLE =>
			if start_radix_i = '1' then
				state_next_s <= WAIT_END_COMP;
				nb_index_next_s <= 0;
				start_but_next_s <= '1';
			end if;
		when WAIT_END_COMP =>
			if done_but_s = '1' then
				if nb_index_s < n_of_b_nat_s-1 then
					start_but_next_s <= '1';
					nb_index_next_s <= nb_index_s + 1;
				else
					state_next_s <= IDLE;
					done_radix_next_s <= '1';
				end if;
			end if;
		end case;
	end process;

	process(a_index_s, a_index_ref_s, a_index_rst_i,
			done_but_s, a2_index_s)
	begin
		a_index_next_s <= a_index_s;
		a_index_ref_next_s <= a_index_ref_s;
		if a_index_rst_i = '1' then
			a_index_next_s <= (others => '0');
			a_index_ref_next_s <= (others => '0');
		elsif done_but_s = '1' then
			a_index_next_s <= a2_index_s;
			a_index_ref_next_s <= a2_index_s;
		end if;
	end process;

	fft_butterfly_inst : entity work.fft_comp_butterfly
	generic map (USE_FIRST_BUFF => USE_FIRST_BUFF, USE_SEC_BUFF => USE_SEC_BUFF,
		DEBUG => DEBUG,
		SHIFT_VAL => SHIFT_VAL, COEFF_SIZE => COEFF_SIZE,
		ADDR_SIZE => ADDR_SIZE, DATA_SIZE => DATA_SIZE)
	port map (clk_i => clk_i, cpu_clk_i => cpu_clk_i, rst_i => rst_i,
		-- test
		t_stage_i => t_stage_i, t_nb_index_i => nb_index_slv_s,
		-- control
		start_butterfly_i => start_but_s, done_but_o => done_but_s,
		-- from previous stage
		a_index_i => a_index_s, a_index_ref_i => a_index_ref_s,
		a_index_o => a_index_out_s,
		s_of_b_i => s_of_b_i, n_of_b_i => n_of_b_i,
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

end architecture fft_loop_radix_1;

