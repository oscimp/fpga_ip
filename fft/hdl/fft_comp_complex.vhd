library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
USE std.textio.ALL;

Entity fft_comp_complex is 
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
		rst_i		: in std_logic;
		-- test
		t_stage_i : in std_logic_vector(ADDR_SIZE-1 downto 0);
		t_nb_index_i : in std_logic_vector(ADDR_SIZE-1 downto 0);
		t_sb_index_i : in std_logic_vector(ADDR_SIZE-1 downto 0);
		-- input data
		data_en_i: in std_logic;
		data_a_re_i  : in std_logic_vector(DATA_SIZE-1 downto 0);
		data_a_im_i  : in std_logic_vector(DATA_SIZE-1 downto 0);
		a_addr_i : in std_logic_vector(ADDR_SIZE-1 downto 0);
		data_b_re_i  : in std_logic_vector(DATA_SIZE-1 downto 0);
		data_b_im_i  : in std_logic_vector(DATA_SIZE-1 downto 0);
		b_addr_i : in std_logic_vector(ADDR_SIZE-1 downto 0);
		coeff_re_i : in std_logic_vector(COEFF_SIZE-1 downto 0);
		coeff_im_i : in std_logic_vector(COEFF_SIZE-1 downto 0);
		-- for the next component
		data_addr_a_o: out std_logic_vector(ADDR_SIZE-1 downto 0);
		data_addr_b_o: out std_logic_vector(ADDR_SIZE-1 downto 0);
		data_a_re_o : out std_logic_vector(DATA_SIZE-1 downto 0);
		data_a_im_o : out std_logic_vector(DATA_SIZE-1 downto 0);
		data_b_re_o : out std_logic_vector(DATA_SIZE-1 downto 0);
		data_b_im_o : out std_logic_vector(DATA_SIZE-1 downto 0);
		comp_done_o : out std_logic
	);
end entity;
Architecture fft_comp_complex_1 of fft_comp_complex is
	constant MULT_SIZE : natural := DATA_SIZE+COEFF_SIZE;
	constant TRICK : natural := 2;
	constant UPPER_SIZE : natural := MULT_SIZE-SHIFT_VAL-TRICK;
	-- internal
	signal res_mult_re_cos : std_logic_vector(MULT_SIZE-1 downto 0);
	signal res_mult_re_sin : std_logic_vector(MULT_SIZE-1 downto 0);
	signal res_mult_im_cos : std_logic_vector(MULT_SIZE-1 downto 0);
	signal res_mult_im_sin : std_logic_vector(MULT_SIZE-1 downto 0);
	signal tmp_real_s, tmp_im_s : std_logic_vector(DATA_SIZE-1 downto 0);
	signal tmp_re_s, tmp_imag_s : std_logic_vector(DATA_SIZE-1 downto 0);
	signal res_mult_re_cos_s : std_logic_vector((UPPER_SIZE)-1 downto 0);
	signal res_mult_re_sin_s : std_logic_vector((UPPER_SIZE)-1 downto 0);
	signal res_mult_im_cos_s : std_logic_vector((UPPER_SIZE)-1 downto 0);
	signal res_mult_im_sin_s : std_logic_vector((UPPER_SIZE)-1 downto 0);
	signal res2_mult_re_cos_s : std_logic_vector((UPPER_SIZE)-1 downto 0);
	signal res2_mult_re_sin_s : std_logic_vector((UPPER_SIZE)-1 downto 0);
	signal res2_mult_im_cos_s : std_logic_vector((UPPER_SIZE)-1 downto 0);
	signal res2_mult_im_sin_s : std_logic_vector((UPPER_SIZE)-1 downto 0);

	signal tmp_a_re_s, tmp_a_im_s : std_logic_vector(DATA_SIZE-1 downto 0);
	signal tmp_b_re_s, tmp_b_im_s : std_logic_vector(DATA_SIZE-1 downto 0);

	-- output result
	signal data_re_a_s : std_logic_vector(DATA_SIZE-1 downto 0);
	signal data_im_a_s : std_logic_vector(DATA_SIZE-1 downto 0);
	signal data_re_b_s : std_logic_vector(DATA_SIZE-1 downto 0);
	signal data_im_b_s : std_logic_vector(DATA_SIZE-1 downto 0);
	signal data_addr_a_s : std_logic_vector(ADDR_SIZE-1 downto 0);
	signal data_addr_b_s : std_logic_vector(ADDR_SIZE-1 downto 0);

	-- new
	signal coeff_re_in_s : std_logic_vector(COEFF_SIZE-1 downto 0);
	signal coeff_im_in_s : std_logic_vector(COEFF_SIZE-1 downto 0);
	signal data_a_re_in_s  : std_logic_vector(DATA_SIZE-1 downto 0);
	signal data_a_im_in_s  : std_logic_vector(DATA_SIZE-1 downto 0);
	signal data_b_re_in_s  : std_logic_vector(DATA_SIZE-1 downto 0);
	signal data_b_im_in_s  : std_logic_vector(DATA_SIZE-1 downto 0);
	signal data_en_s, data2_en_s : std_logic;
	signal truc : std_logic_vector(MULT_SIZE-SHIFT_VAL-1 downto 0);
	--file OUTPUT: text open write_mode is "./debug.txt";
begin
	data_a_re_o <= data_re_a_s;
	data_a_im_o <= data_im_a_s;
	data_b_re_o <= data_re_b_s;
	data_b_im_o <= data_im_b_s;
	data_addr_a_o <= data_addr_a_s;
	data_addr_b_o <= data_addr_b_s;

	use_first_buff_gen : if USE_FIRST_BUFF = true generate
	process(clk_i)
	begin
		if rising_edge(clk_i) then
			if rst_i = '1' then
				data_a_re_in_s <= (others => '0');
				data_a_im_in_s <= (others => '0');
				data_b_re_in_s <= (others => '0');
				data_b_im_in_s <= (others => '0');
				coeff_re_in_s <= (others => '0');
				coeff_im_in_s <= (others => '0');
				data_en_s <= '0';
			else
				data_en_s <= data_en_i;
				data_a_re_in_s <= data_a_re_in_s;
				data_a_im_in_s <= data_a_im_in_s;
				data_b_re_in_s <= data_b_re_in_s;
				data_b_im_in_s <= data_b_im_in_s;
				coeff_re_in_s <= coeff_re_in_s;
				coeff_im_in_s <= coeff_im_in_s;
				if data_en_i = '1' then
					data_a_re_in_s <= data_a_re_i;
					data_a_im_in_s <= data_a_im_i;
					data_b_re_in_s <= data_b_re_i;
					data_b_im_in_s <= data_b_im_i;
					coeff_re_in_s <= coeff_re_i;
					coeff_im_in_s <= coeff_im_i;
				end if;
			end if;
		end if;
	end process;
	end generate use_first_buff_gen;
	not_use_first_buff : if USE_FIRST_BUFF = false generate
		data_a_re_in_s <= data_a_re_i;
		data_a_im_in_s <= data_a_im_i;
		data_b_re_in_s <= data_b_re_i;
		data_b_im_in_s <= data_b_im_i;
		coeff_re_in_s <= coeff_re_i;
		coeff_im_in_s <= coeff_im_i;
		data_en_s <= data_en_i;
	end generate not_use_first_buff;

	res_mult_re_cos <= std_logic_vector(signed(data_b_re_in_s) *
							signed(coeff_re_in_s));
	res_mult_re_sin <= std_logic_vector(signed(data_b_re_in_s) *
							signed(coeff_im_in_s));
	res_mult_im_cos <= std_logic_vector(signed(data_b_im_in_s) *
							signed(coeff_re_in_s));
	res_mult_im_sin <= std_logic_vector(signed(data_b_im_in_s) *
							signed(coeff_im_in_s));

	res_mult_re_cos_s <= res_mult_re_cos(MULT_SIZE-TRICK-1 downto SHIFT_VAL);
	res_mult_re_sin_s <= res_mult_re_sin(MULT_SIZE-TRICK-1 downto SHIFT_VAL);
	res_mult_im_cos_s <= res_mult_im_cos(MULT_SIZE-TRICK-1 downto SHIFT_VAL);
	res_mult_im_sin_s <= res_mult_im_sin(MULT_SIZE-TRICK-1 downto SHIFT_VAL);
	truc <= res_mult_re_cos(MULT_SIZE-1 downto SHIFT_VAL);

	use_sec_buff_gen : if USE_SEC_BUFF = true generate
	process(clk_i)
	begin
		if rising_edge(clk_i) then
			res2_mult_re_cos_s <= res_mult_re_cos_s;
			res2_mult_re_sin_s <= res_mult_re_sin_s;
			res2_mult_im_cos_s <= res_mult_im_cos_s;
			res2_mult_im_sin_s <= res_mult_im_sin_s;
			data2_en_s <= data_en_s;
		end if;
	end process;
	end generate use_sec_buff_gen;
	not_use_sec_buff : if USE_SEC_BUFF = false generate
		res2_mult_re_cos_s <= res_mult_re_cos_s;
		res2_mult_re_sin_s <= res_mult_re_sin_s;
		res2_mult_im_cos_s <= res_mult_im_cos_s;
		res2_mult_im_sin_s <= res_mult_im_sin_s;
		data2_en_s <= data_en_s;
	end generate not_use_sec_buff;

	tmp_b_re_s <= std_logic_vector(signed(data_a_re_in_s) - signed(res2_mult_re_cos_s) +
									signed(res2_mult_im_sin_s));
	tmp_b_im_s <= std_logic_vector(signed(data_a_im_in_s) - signed(res2_mult_re_sin_s) -
									signed(res2_mult_im_cos_s));
	tmp_a_re_s <= std_logic_vector(signed(data_a_re_in_s) + signed(res2_mult_re_cos_s) -
									signed(res2_mult_im_sin_s));
	tmp_a_im_s <= std_logic_vector(signed(data_a_im_in_s) + signed(res2_mult_re_sin_s) +
									signed(res2_mult_im_cos_s));


	process(clk_i)
	begin
		if rising_edge(clk_i) then
			if rst_i = '1' then
				data_re_a_s <= (others => '0');
				data_im_a_s <= (others => '0');
				data_re_b_s <= (others => '0');
				data_im_b_s <= (others => '0');
				data_addr_a_s <= (others => '0');
				data_addr_b_s <= (others => '0');
				comp_done_o <= '0';
			else
				data_re_a_s <= data_re_a_s;
				data_im_a_s <= data_im_a_s;
				data_re_b_s <= data_re_b_s;
				data_im_b_s <= data_im_b_s;
				data_addr_a_s <= data_addr_a_s;
				data_addr_b_s <= data_addr_b_s;
				comp_done_o <= '0';

				if data2_en_s = '1' then
					data_re_a_s <= tmp_a_re_s;
					data_im_a_s <= tmp_a_im_s;
					data_re_b_s <= tmp_b_re_s;
					data_im_b_s <= tmp_b_im_s;

					data_addr_a_s <= a_addr_i;
					data_addr_b_s <= b_addr_i;
					comp_done_o <= '1';
				end if;
			end if;
		end if;
	end process;

	debug_display : if DEBUG = true generate
	dump_res: process(clk_i)
		use Std.TextIO.all;
		variable lp: line;
		variable pv: Std_Logic;
	begin
		if rising_edge(clk_i) then
			if data_en_i = '1' then
				write(lp, string'("stage"));
				write(lp, integer'image(to_integer(signed(t_stage_i))));
				write(lp, string'(" "));
				write(lp, string'("nb_index"));
				write(lp, integer'image(to_integer(signed(t_nb_index_i))));
				write(lp, string'(" "));
				write(lp, string'("sb_index"));
				write(lp, integer'image(to_integer(signed(t_sb_index_i))));
				write(lp, string'(" "));
				write(lp, string'("a_index"));
				write(lp, integer'image(to_integer(unsigned(a_addr_i))));
				write(lp, string'(" "));
				write(lp, string'("b_index"));
				write(lp, integer'image(to_integer(unsigned(b_addr_i))));

				write(lp, string'(" "));
				write(lp, integer'image(to_integer(signed(coeff_re_in_s))));
				write(lp, string'(" "));
				write(lp, integer'image(to_integer(signed(coeff_im_in_s))));

				write(lp, string'(" "));
				write(lp, integer'image(to_integer(signed(data_b_re_in_s))));
				write(lp, string'(" "));
				write(lp, integer'image(to_integer(signed(data_b_im_in_s))));

				write(lp, string'(" "));
				write(lp, integer'image(to_integer(signed(res_mult_re_cos_s))));
				write(lp, string'(" "));
				write(lp, integer'image(to_integer(signed(res_mult_re_sin_s))));
				write(lp, string'(" "));
				write(lp, integer'image(to_integer(signed(res_mult_im_cos_s))));
				write(lp, string'(" "));
				write(lp, integer'image(to_integer(signed(res_mult_im_sin_s))));

				write(lp, string'(" "));
				write(lp, integer'image(to_integer(signed(tmp_a_re_s))));
				write(lp, string'(" "));
				write(lp, integer'image(to_integer(signed(tmp_a_im_s))));
				write(lp, string'(" "));
				write(lp, integer'image(to_integer(signed(tmp_b_re_s))));
				write(lp, string'(" "));
				write(lp, integer'image(to_integer(signed(tmp_b_im_s))));
				writeline(OUTPUT, lp);
			end if;
		end if;
	end process;
	end generate debug_display;
end architecture fft_comp_complex_1;

