library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

Entity fft_comp_butterfly is 
	generic (
		USE_FIRST_BUFF : boolean := true;
		USE_SEC_BUFF : boolean := true;
		DEBUG : boolean := false;
		SHIFT_VAL : natural := 16;
		COEFF_SIZE : natural := 16;
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
		t_nb_index_i : in std_logic_vector(ADDR_SIZE-1 downto 0);
		-- control
		start_butterfly_i : in std_logic;
		done_but_o : out std_logic;
		-- from previous stage
		a_index_i : in std_logic_vector(ADDR_SIZE-1 downto 0);
		a_index_ref_i : in std_logic_vector(ADDR_SIZE-1 downto 0);
		a_index_o : out std_logic_vector(ADDR_SIZE-1 downto 0);
		n_of_b_i  : in std_logic_vector(ADDR_SIZE-1 downto 0);
		s_of_b_i  : in std_logic_vector(ADDR_SIZE-1 downto 0);

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
Architecture fft_comp_butterfly_1 of fft_comp_butterfly is
	type state_type is (IDLE, WAIT_END_COMP);
	signal state_s : state_type;
	signal data_a_re_s, data_a_im_s : std_logic_vector(DATA_SIZE-1 downto 0);
	signal data_b_re_s, data_b_im_s : std_logic_vector(DATA_SIZE-1 downto 0);
	signal coeff_re_s, coeff_im_s : std_logic_vector(COEFF_SIZE-1 downto 0);
	signal a_index_s : std_logic_vector(ADDR_SIZE-1 downto 0);
	signal a_index_out_s : std_logic_vector(ADDR_SIZE-1 downto 0);
	signal b_index_s : std_logic_vector(ADDR_SIZE-1 downto 0);
	signal a2_index_s : std_logic_vector(ADDR_SIZE-1 downto 0);
	signal sb_index : natural range 0 to 2**ADDR_SIZE-1;
	-- state 
	signal enable_data_s, enable_next_comp_s : std_logic;
	-- coeff
	signal clear_accum_s : std_logic;
	signal s_index_plus_one_s : std_logic_vector(ADDR_SIZE-1 downto 0);
	signal s_of_b_nat_s : natural range 0 to 2**ADDR_SIZE-1;
	signal sob_minus_one_s : std_logic_vector(ADDR_SIZE-1 downto 0);
	-- complex
	signal comp_done_s : std_logic;
	signal cplx_addr_a_s : std_logic_vector(ADDR_SIZE-1 downto 0);
	signal cplx_addr_b_s : std_logic_vector(ADDR_SIZE-1 downto 0);
	signal cplx_data_a_re_s : std_logic_vector(DATA_SIZE-1 downto 0);
	signal cplx_data_a_im_s : std_logic_vector(DATA_SIZE-1 downto 0);
	signal cplx_data_b_re_s : std_logic_vector(DATA_SIZE-1 downto 0);
	signal cplx_data_b_im_s : std_logic_vector(DATA_SIZE-1 downto 0);
	signal sb_index_slv_s : std_logic_vector(ADDR_SIZE-1 downto 0);

	-- new
	signal state_next_s : state_type;
	signal clear_accum_next_s : std_logic;
	signal enable_next_data_s : std_logic;
	signal a_index_next_s : std_logic_vector(ADDR_SIZE-1 downto 0);
	signal done_but_next_o : std_logic;
	signal sb_index_next_s : natural range 0 to 2**ADDR_SIZE-1;
begin
	sb_index_slv_s <= std_logic_vector(to_unsigned(sb_index, ADDR_SIZE));

	a_index_o <= a_index_s;
	s_of_b_nat_s <= to_integer(unsigned(s_of_b_i));
	s_index_plus_one_s <= std_logic_vector(to_unsigned(sb_index + 1, ADDR_SIZE));
	sob_minus_one_s <= std_logic_vector(unsigned(s_of_b_i)-1);
	
	b_index_s <= std_logic_vector(unsigned(a_index_s) + unsigned(s_of_b_i));
	
	a2_index_s <= a_index_ref_i when
		((s_index_plus_one_s and sob_minus_one_s) = (ADDR_SIZE-1 downto 0 =>
		'0')) else 
		std_logic_vector(unsigned(a_index_s)+1);

	process(clk_i)
	begin
		if rising_edge(clk_i) then
			if rst_i = '1' then
				state_s <= IDLE;
				clear_accum_s <= '0';
				enable_data_s <= '0';
				a_index_s <= (others => '0');
				done_but_o <= '0';
				sb_index <= 0;
			else
				state_s <= state_next_s;
				clear_accum_s <= clear_accum_next_s;
				enable_data_s <= enable_next_data_s;
				a_index_s <= a_index_next_s;
				done_but_o <= done_but_next_o;
				sb_index <= sb_index_next_s;
			end if;
		end if;
	end process;

	process(state_s, a_index_s, sb_index, start_butterfly_i,
			a_index_i, comp_done_s, a2_index_s, s_of_b_nat_s)
	begin
		state_next_s <= state_s;
		enable_next_data_s <= '0';
		done_but_next_o <= '0';
		sb_index_next_s <= sb_index;
		case state_s is
		when IDLE =>
			if start_butterfly_i = '1' then
				sb_index_next_s <= 0;
				state_next_s <= WAIT_END_COMP;
				enable_next_data_s <= '1';
			end if;
		when WAIT_END_COMP =>
			if comp_done_s = '1' then
				if sb_index < s_of_b_nat_s-1 then
					sb_index_next_s <= sb_index + 1;
					enable_next_data_s <= '1';
				else
					state_next_s <= IDLE;
					done_but_next_o <= '1';
					sb_index_next_s <= 0;
				end if;
			end if;
		end case;
	end process;

	process(comp_done_s, sb_index, s_of_b_nat_s)
	begin
		clear_accum_next_s <= '0';
		if comp_done_s = '1' then
			if sb_index = s_of_b_nat_s -1 then
				clear_accum_next_s <= '1';
			end if;
		end if;
	end process;

	process(a_index_s, a_index_i, a2_index_s, start_butterfly_i, comp_done_s)
	begin
		a_index_next_s <= a_index_s;
		if start_butterfly_i = '1' then
			a_index_next_s <= a_index_i;
		elsif comp_done_s = '1' then
			a_index_next_s <= a2_index_s;
		end if;
	end process;

	fft_data_hand_inst : entity work.fft_data_handler
	generic map (ADDR_SIZE => ADDR_SIZE, DATA_SIZE => DATA_SIZE)
	port map (clk_i => clk_i, rst_i => rst_i,
		-- control
		s_of_b_i => s_of_b_i,
		-- data from first stage
		fs_data_en_i => data_en_i, fs_data_addr_i => data_addr_i,
		fs_data_re_i => data_re_i, fs_data_im_i => data_im_i,
		-- data form compute
		cmp_start_i => enable_data_s, cmp_a_addr_i => a_index_s,
		cmp_data_a_re_o => data_a_re_s, cmp_data_a_im_o => data_a_im_s,
		cmp_data_b_re_o => data_b_re_s, cmp_data_b_im_o => data_b_im_s,
		cmp_b_addr_i => b_index_s, cmp_data_en_o => enable_next_comp_s,
		-- data from compute
		cplx_data_a_re_i => cplx_data_a_re_s,
		cplx_data_a_im_i => cplx_data_a_im_s,
		cplx_data_b_re_i => cplx_data_b_re_s,
		cplx_data_b_im_i => cplx_data_b_im_s,
		cplx_addr_a_i => cplx_addr_a_s, cplx_addr_b_i => cplx_addr_b_s, 
		cplx_data_en_i => comp_done_s,
		--results
		res_re_o => res_re_o, res_im_o => res_im_o, res_addr_i => res_addr_i);


	fft_c_c_inst : entity work.fft_comp_complex
	generic map (USE_FIRST_BUFF => USE_FIRST_BUFF, USE_SEC_BUFF => USE_SEC_BUFF,
		DEBUG => DEBUG,
		SHIFT_VAL => SHIFT_VAL, COEFF_SIZE => COEFF_SIZE,
		ADDR_SIZE => ADDR_SIZE, DATA_SIZE => DATA_SIZE)
	port map (clk_i => clk_i, rst_i => rst_i,
		-- test
		t_stage_i => t_stage_i, t_nb_index_i => t_nb_index_i,
		t_sb_index_i => sb_index_slv_s,
		-- control
		comp_done_o => comp_done_s, data_en_i => enable_next_comp_s,
		-- input data
		data_a_re_i => data_a_re_s, data_a_im_i => data_a_im_s,
		data_b_re_i => data_b_re_s, data_b_im_i => data_b_im_s,
		coeff_re_i => coeff_re_s, coeff_im_i => coeff_im_s,
		a_addr_i => a_index_s, b_addr_i => b_index_s,
		-- for the next component
		data_addr_a_o => cplx_addr_a_s, data_addr_b_o => cplx_addr_b_s,
		data_a_re_o => cplx_data_a_re_s, data_a_im_o => cplx_data_a_im_s,
		data_b_re_o => cplx_data_b_re_s, data_b_im_o => cplx_data_b_im_s);

	fft_coeff_hand_inst : entity work.fft_coeff_handler 
	generic map ( DATA_SIZE => COEFF_SIZE, ADDR_SIZE => ADDR_SIZE)
  	port map (cpu_clk_i => cpu_clk_i, clk_i => clk_i, rst_i => rst_i,
		-- from CPU
		coeff_re_we_i => coeff_re_en_i, coeff_re_addr_i => coeff_re_addr_i,
		coeff_im_we_i => coeff_im_en_i, coeff_im_addr_i => coeff_im_addr_i,
		read_coeff_re_o => read_coeff_re_o, read_coeff_im_o => read_coeff_im_o,
		coeff_re_i => coeff_re_i, coeff_im_i => coeff_im_i,
		-- for comp
		n_of_b_i => n_of_b_i, clear_accum_i => clear_accum_s,
		enable_incr_i => enable_data_s,
		coeff_re_o => coeff_re_s, coeff_im_o => coeff_im_s);
end architecture fft_comp_butterfly_1;

