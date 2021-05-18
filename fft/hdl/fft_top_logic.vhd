library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

Entity fft_top_logic is 
	generic (
		USE_EOF : boolean := true;
		USE_FIRST_BUFF : boolean := true;
		USE_SEC_BUFF : boolean := true;
		DEBUG : boolean := false;
		LOG_2_N_FFT : natural := 8;
		N_FFT : natural := 2048;
		COEFF_SIZE : natural := 16;
		SHIFT_VAL : natural := 16;
		ADDR_SIZE : natural := 10;
		DATA_SIZE : natural := 32;
		DATA_IN_SIZE : natural := 16
	);
	port (
		-- Syscon signals
		clk_i		: in std_logic;
		cpu_clk_i	: in std_logic;
		cpu_rst_i	: in std_logic;
		data_rst_i	: in std_logic;
		-- input data
		data_i  : in std_logic_vector(DATA_IN_SIZE-1 downto 0);
		data_en_i : in std_logic;
		data_eof_i : in std_logic;
		--configuration
		read_coeff_re_o : out std_logic_vector(COEFF_SIZE-1 downto 0);
		read_coeff_im_o : out std_logic_vector(COEFF_SIZE-1 downto 0);
		coeff_re_i : in std_logic_vector(COEFF_SIZE-1 downto 0);
		coeff_im_i : in std_logic_vector(COEFF_SIZE-1 downto 0);
		coeff_re_addr_i : std_logic_vector(ADDR_SIZE-1 downto 0);
		coeff_im_addr_i : std_logic_vector(ADDR_SIZE-1 downto 0);
		coeff_re_en_i : std_logic;
		coeff_im_en_i : std_logic;
		-- results
		res_re_o  : out std_logic_vector(DATA_SIZE-1 downto 0);
		res_im_o  : out std_logic_vector(DATA_SIZE-1 downto 0);
		res_en_o : out std_logic;
		res_eof_o : out std_logic
	);
end entity;
Architecture fft_top_logic_1 of fft_top_logic is
	constant ALL_IN_ONE : std_logic_vector(ADDR_SIZE-1 downto 0) :=
		(ADDR_SIZE-1 downto 0 => '1');
	signal NB_ELEM : natural := 2**ADDR_SIZE;
	type state_type is (IDLE, WAIT_END_COMP, WAIT_END_TRANSMIT, WAIT_EOF);
	signal state_s, state_next_s : state_type;
	signal data_addr_s : std_logic_vector(ADDR_SIZE-1 downto 0);
	signal data_addr2_s : std_logic_vector(ADDR_SIZE-1 downto 0);
	signal data_addr_next_s: std_logic_vector(ADDR_SIZE-1 downto 0);
	signal start_fft_s, done_fft_s : std_logic;
	signal data_in_en_s : std_logic;
	signal data_in_eof_s : std_logic;
	-- results
	signal result_addr_s : std_logic_vector(ADDR_SIZE-1 downto 0);
	signal tmp_im_s : std_logic_vector(DATA_SIZE-1 downto 0);
	signal tmp_re_s : std_logic_vector(DATA_SIZE-1 downto 0);
	signal done_transmit_s : std_logic;
	-- size conversion
	signal data_in_s : std_logic_vector(DATA_SIZE-1 downto 0);
	signal transmit_en_s, transmit_en_next_s : std_logic;
	signal start_fft_next_s : std_logic;
begin
	same_size : if DATA_IN_SIZE = DATA_SIZE generate
		data_in_s <= data_i;
	end generate same_size;

	diff_size : if DATA_IN_SIZE /= DATA_SIZE generate
		data_in_s <= (DATA_SIZE-1 downto DATA_IN_SIZE => data_i(DATA_IN_SIZE-1))&data_i;
	end generate diff_size;
	
	process(clk_i)
	begin
		if rising_edge(clk_i) then
			if data_rst_i = '1' then
				if USE_EOF = false then
					state_s <= IDLE;
				else
					state_s <= WAIT_EOF;
				end if;
				transmit_en_s <= '0';
				data_addr2_s <= (others => '0');
				start_fft_s <= '0';
			else
				state_s <= state_next_s;
				transmit_en_s <= transmit_en_next_s;
				data_addr2_s <= data_addr_next_s;
				start_fft_s <= start_fft_next_s;
			end if;
		end if;
	end process;

	process(state_s, start_fft_s, done_fft_s,
		data_in_en_s, data_in_eof_s,
		transmit_en_s, done_transmit_s, data_addr2_s)
	begin
		state_next_s	<= state_s;
		transmit_en_next_s <= transmit_en_s;
		data_addr_next_s <= data_addr2_s;
		start_fft_next_s <= '0';

		case state_s is
		when IDLE =>
			if data_in_en_s = '1' then
				if data_addr2_s = ALL_IN_ONE  then
					data_addr_next_s <= (others => '0');
					start_fft_next_s <= '1';
					state_next_s <= WAIT_END_COMP;
				else
					data_addr_next_s <= 
						std_logic_vector(unsigned(data_addr2_s) + 1); 
				end if;
			end if;
			--if start_fft_s = '1' then
			--	state_next_s <= WAIT_END_COMP;
			--end if;
		when WAIT_END_COMP =>
			if done_fft_s = '1' then
				state_next_s <= WAIT_END_TRANSMIT;
				transmit_en_next_s <= '1';
			end if;
		when WAIT_END_TRANSMIT =>
			if done_transmit_s = '1' then
				if USE_EOF = false then
					state_next_s <= IDLE;
				else
					state_next_s <= WAIT_EOF;
				end if;
				transmit_en_next_s <= '0';
			end if;
		when WAIT_EOF =>
			if data_in_eof_s = '1' then
				state_next_s <= IDLE;
			end if;
		end case;
	end process;

	--data_in_en_s <= data_en_i when (state_s = IDLE and start_fft_s = '0') else '0';
	data_in_en_s <= data_en_i when (state_s = IDLE ) else '0';
	data_in_eof_s <= data_en_i and data_eof_i when (state_s = WAIT_EOF) else '0';
	process(data_addr2_s)
	begin
		boucle_test :for i in 0 to ADDR_SIZE-1 loop
			data_addr_s(i) <= data_addr2_s(ADDR_SIZE-1-i);
		end loop;
	end process;

--	process(clk_i, data_rst_i)
--	begin
--		if data_rst_i = '1' then
--			data_addr2_s <= (others => '0');
--			start_fft_s <= '0';
--		elsif rising_edge(clk_i) then
--			start_fft_s <= '0';
--			data_addr2_s <= data_addr2_s;
--			if data_in_en_s = '1' then
--				if to_integer(unsigned(data_addr2_s)) < NB_ELEM  then
--					data_addr2_s <= 
--						std_logic_vector(unsigned(data_addr2_s) + 1); 
--				else
--					data_addr2_s <= (others => '0');
--					start_fft_s <= '1';
--				end if;
--			else
--				if to_integer(unsigned(data_addr2_s)) = NB_ELEM-1  then
--					data_addr2_s <= (others => '0');
--					start_fft_s <= '1';
--				end if;
--			end if;
--		end if;
--	end process;

--	res_re_o <= tmp_re_s;
--	res_im_o <= tmp_im_s;


--	process(clk_i, data_rst_i)
--	begin
--		if data_rst_i = '1' then
--			result_addr_s <= (others => '0');
--			res_en_o <= '0';
--			done_transmit_s <= '0';
--		elsif rising_edge(clk_i) then
--			result_addr_s <= result_addr_s;
--			res_en_o <= '0';
--			done_transmit_s <= '0';
--			if state_s = WAIT_END_TRANSMIT then
--				res_en_o <= '1';
--				result_addr_s <= std_logic_vector(unsigned(result_addr_s)
--						+ 1);
--				if result_addr_s = (ADDR_SIZE-1 downto 0 => '1') then
--					done_transmit_s <= '1';
--				end if;
--			else
--				result_addr_s <= (others => '0');
--			end if;
--		end if;
--	end process;

	res_eof_o <= done_transmit_s;

	transmitter : entity work.fft_transfert  
	generic map (ADDR_SIZE => ADDR_SIZE, DATA_SIZE => DATA_SIZE)
	port map (clk_i => clk_i, rst_i => data_rst_i,
		transmit_en_o => transmit_en_s, done_transmit_o => done_transmit_s,
		res_re_i => tmp_re_s, res_im_i => tmp_im_s, res_addr_o => result_addr_s,
		res_re_o  => res_re_o, res_im_o => res_im_o, res_en_o => res_en_o);

	fft_loop_stage_inst : entity work.fft_loop_stage
	generic map (USE_FIRST_BUFF => USE_FIRST_BUFF, USE_SEC_BUFF => USE_SEC_BUFF,
		DEBUG => DEBUG,
		LOG_2_N_FFT => LOG_2_N_FFT, N_FFT => N_FFT,
		SHIFT_VAL => SHIFT_VAL, COEFF_SIZE => COEFF_SIZE,
		ADDR_SIZE => ADDR_SIZE, DATA_SIZE => DATA_SIZE)
	port map (clk_i => clk_i, cpu_clk_i => cpu_clk_i, rst_i => data_rst_i,
		-- control
		start_fft_i => start_fft_s, done_fft_o => done_fft_s,
		-- input data
		data_re_i => data_in_s, data_im_i => (others => '0'),
		data_addr_i => data_addr_s, data_en_i => data_in_en_s,
		--configuration
		read_coeff_re_o => read_coeff_re_o, read_coeff_im_o => read_coeff_im_o,
		coeff_re_i => coeff_re_i, coeff_im_i => coeff_im_i,
		coeff_re_addr_i => coeff_re_addr_i, coeff_re_en_i => coeff_re_en_i,
		coeff_im_addr_i => coeff_im_addr_i, coeff_im_en_i => coeff_im_en_i,
		-- results
		res_re_o => tmp_re_s, res_im_o => tmp_im_s,
		res_addr_i => result_addr_s);

end architecture fft_top_logic_1;

