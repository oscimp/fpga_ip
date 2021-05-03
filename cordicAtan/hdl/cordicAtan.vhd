library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
use ieee.math_real.all;

Entity cordicAtan is 
	generic (
		NB_ITER      : natural := 25;
		DATA_SIZE    : natural := 32;
		OUTPUT_SIZE  : natural := 28;
		PI_VALUE     : natural := 52707179 -- M_PI * 2**(NB_ITER-1)
	);
	port (
		-- input data
		data_en_i  : in std_logic;
		data_i_i   : in std_logic_vector(DATA_SIZE-1 downto 0);
		data_q_i   : in std_logic_vector(DATA_SIZE-1 downto 0);
		data_clk_i : in std_logic;
		data_rst_i : in std_logic;
		-- output
		atan_o     : out std_logic_vector(OUTPUT_SIZE-1 downto 0);
		atan_en_o  : out std_logic;
		atan_clk_o : out std_logic;
		atan_rst_o : out std_logic
	);
end entity;
Architecture bev of cordicAtan is
	constant ATAN_SIZE : natural := NB_ITER-1;
	constant SHIFT_FACTOR : natural := NB_ITER-1;

	constant RESIZE_DATA_SIZE : natural := 2+DATA_SIZE+SHIFT_FACTOR;
	constant ALPHA_SIZE : natural := ATAN_SIZE+4;
	type atan_tab is array (natural range <>) 
			of std_logic_vector(ALPHA_SIZE-1 downto 0);
	type data_tab is array (natural range <>)
			of std_logic_vector(RESIZE_DATA_SIZE-1 downto 0);
	type sign_tab is array (natural range <>)
			of std_logic_vector(3 downto 0);

	signal data_i_in_s   : std_logic_vector(RESIZE_DATA_SIZE-1 downto 0);
	signal data_q_in_s   : std_logic_vector(RESIZE_DATA_SIZE-1 downto 0);
	signal data_en_in_s  : std_logic;

	signal data_i_s      : data_tab(NB_ITER downto 0);
	signal data_q_s      : data_tab(NB_ITER downto 0);
	signal data_en_s     : std_logic_vector(NB_ITER downto 0);
	signal atan_s        : atan_tab(NB_ITER downto 0);
	signal sign_s        : sign_tab(NB_ITER downto 0);

	signal sign_tmp_s    : std_logic_vector(3 downto 0);
	signal atan_corr_s   : std_logic_vector(ALPHA_SIZE-1 downto 0);
	signal atan_fin_s    : std_logic_vector(ALPHA_SIZE-1 downto 0);
	signal data_en_fin_s : std_logic;

	constant pi_resize_s : std_logic_vector(ALPHA_SIZE -1 downto 0) 
							:= std_logic_vector(to_signed(PI_VALUE, ALPHA_SIZE));
begin
	atan_clk_o <= data_clk_i;
	atan_rst_o <= data_rst_i;

	process(data_clk_i) begin
		if rising_edge(data_clk_i) then
			data_en_in_s  <= data_en_i;
			if (data_en_i = '1') then
				data_i_in_s <= data_i_i&(2+SHIFT_FACTOR-1 downto 0 => '0');
				data_q_in_s <= data_q_i&(2+SHIFT_FACTOR-1 downto 0 => '0');
			else
				data_i_in_s <= data_i_in_s;
				data_q_in_s <= data_q_in_s;
			end if;
		end if;
	end process;


	data_en_s(0) <= data_en_in_s;
	data_i_s(0)  <= data_i_in_s;
	data_q_s(0)  <= data_q_in_s;
	atan_s(0)    <= (others => '0');
	sign_s(0)(3) <= data_i_in_s(RESIZE_DATA_SIZE-1); -- x
	sign_s(0)(2) <= '1' when data_i_i = (RESIZE_DATA_SIZE-1 downto 0 => '0') else '0';
	sign_s(0)(1) <= data_q_in_s(RESIZE_DATA_SIZE-1); -- y
	sign_s(0)(0) <= '1' when data_q_i = (RESIZE_DATA_SIZE-1 downto 0 => '0') else '0';

	generate_cordicAtan: for i in 0 to NB_ITER-1 generate
		cordicAtan_impl_inst : entity work.cordicAtan_impl
		generic map (
			SHIFT_V		=> i,
			NB_ITER     => NB_ITER,
			ATAN_SIZE	=> ATAN_SIZE,
			ALPHA_SIZE	=> ALPHA_SIZE,
			DATA_SIZE	=> RESIZE_DATA_SIZE
		)
		port map (
			-- Syscon signals
			clk			=> data_clk_i,
			-- sign
			sign_i		=> sign_s(i),
			sign_o		=> sign_s(i+1),
			-- input data
			data_en_i	=> data_en_s(i),
			data_i_i	=> data_i_s(i),
			data_q_i	=> data_q_s(i),
			data_atan_i	=> atan_s(i),
			-- input data
			data_en_o	=> data_en_s(i+1),
			data_i_o	=> data_i_s(i+1),
			data_q_o	=> data_q_s(i+1),
			data_atan_o	=> atan_s(i+1)
		);
	end generate;

	sign_tmp_s <= sign_s(NB_ITER);

	-- correction
	process(sign_tmp_s, atan_s)
	begin
		case sign_tmp_s is
		-------------------
		-- special cases --
		-------------------
		-- x == y == 0 => atan = 0
		when "0101" =>
			atan_corr_s <= (others => '0');
		-- x == 0 +/- PI
		-- y > 0 => atan = PI/2
		when "0100" =>
			atan_corr_s <= '0'&pi_resize_s(ALPHA_SIZE-1 downto 1);
		-- y < 0 => atan = -PI/2
		when "0110" =>
			atan_corr_s <= std_logic_vector(
				-signed('0'&pi_resize_s(ALPHA_SIZE-1 downto 1)));
		-- y == 0 +/- PI
		-- x > 0 => atan = 0
		when "0001" =>
			atan_corr_s <= (others => '0');
		-- x < 0 => atan = PI
		when "1001" =>
			atan_corr_s <= pi_resize_s;
		-------------------
		-- classic cases --
		-------------------
		when "1010" => -- all < 0
			atan_corr_s <= std_logic_vector(signed(atan_s(NB_ITER))
					- signed(pi_resize_s));
			-- x < 0 and y >= 0  (in fact y > 0 because y == 0 already treated
		when "1000" =>
			atan_corr_s <= std_logic_vector(signed(atan_s(NB_ITER))
					+ signed(pi_resize_s));
		when others =>
			atan_corr_s <= atan_s(NB_ITER);
		end case;
	end process;

	process(data_clk_i) 
	begin
		if rising_edge(data_clk_i) then
			data_en_fin_s <= data_en_s(NB_ITER);
			if data_rst_i = '1' then
				atan_fin_s <= (others => '0');
			elsif data_en_s(NB_ITER) = '1' then
				atan_fin_s <= atan_corr_s;
			else
				atan_fin_s <= atan_fin_s;
			end if;
		end if;
	end process;

	same_size_gen: if ALPHA_SIZE = OUTPUT_SIZE generate
		atan_o <= atan_fin_s;
	end generate;

	less_size_gen: if ALPHA_SIZE < OUTPUT_SIZE generate
		atan_o <= (OUTPUT_SIZE-1 downto ALPHA_SIZE => atan_fin_s(ATAN_SIZE-1))
					&atan_fin_s;
	end generate;

	gt_size_gen: if ALPHA_SIZE > OUTPUT_SIZE generate
		atan_o <= atan_fin_s(ALPHA_SIZE-1 downto ALPHA_SIZE-OUTPUT_SIZE);
	end generate;

	atan_en_o <= data_en_fin_s;
end architecture bev;
