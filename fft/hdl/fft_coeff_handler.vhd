library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

Entity fft_coeff_handler is 
	generic (
		ADDR_SIZE : natural := 10;
		DATA_SIZE : natural := 16
	);
	port 
	(
		-- Syscon signals
		clk_i		: in std_logic;
		cpu_clk_i   : in std_logic;
		rst_i		: in std_logic;
		-- input data
		read_coeff_re_o : out std_logic_vector(DATA_SIZE-1 downto 0);
		read_coeff_im_o : out std_logic_vector(DATA_SIZE-1 downto 0);
		coeff_re_i : in std_logic_vector(DATA_SIZE-1 downto 0);
		coeff_re_addr_i : std_logic_vector(ADDR_SIZE-1 downto 0);
		coeff_re_we_i : std_logic;
		coeff_im_i : in std_logic_vector(DATA_SIZE-1 downto 0);
		coeff_im_addr_i : std_logic_vector(ADDR_SIZE-1 downto 0);
		coeff_im_we_i : std_logic;
		-- control
		n_of_b_i : in std_logic_vector(ADDR_SIZE-1 downto 0);
		clear_accum_i : in std_logic;
		enable_incr_i : in std_logic;

		-- output data
		coeff_re_o : out std_logic_vector(DATA_SIZE-1 downto 0);
		coeff_im_o : out std_logic_vector(DATA_SIZE-1 downto 0)
	);
end entity;
Architecture fft_coeff_handler_1 of fft_coeff_handler is
	signal coeff_re_s, coeff_im_s : std_logic_vector(DATA_SIZE-1 downto 0);
	signal tmp_re_s, tmp_im_s : std_logic_vector(DATA_SIZE-1 downto 0);
	signal addr_s : std_logic_vector(ADDR_SIZE -1 downto 0);
	signal tmp_incr_s : std_logic;

	signal addr_next_s : std_logic_vector(ADDR_SIZE-1 downto 0);
begin
	coeff_re_o <= coeff_re_s;
	coeff_im_o <= coeff_im_s;

	process(clk_i)
	begin
		if rising_edge(clk_i) then
			if rst_i = '1' then
				coeff_re_s <= (others => '0');
				coeff_im_s <= (others => '0');
				tmp_incr_s <= '0';
			else
				coeff_re_s <= coeff_re_s;
				coeff_im_s <= coeff_im_s;
				tmp_incr_s <= enable_incr_i;
				if enable_incr_i = '1' then
					coeff_re_s <= tmp_re_s;
					coeff_im_s <= tmp_im_s;
				end if;
			end if;
		end if;
	end process;

	process(clk_i)
	begin
		if rising_edge(clk_i) then
			if rst_i = '1' then
				addr_s <= (others => '0');
			else
				addr_s <= addr_next_s;
			end if;
		end if;
	end process;

	process(addr_s, clear_accum_i, enable_incr_i, n_of_b_i)
	begin
		addr_next_s <= addr_s;
		if clear_accum_i = '1' then
			addr_next_s <= (others => '0');
		elsif enable_incr_i = '1' then
			addr_next_s <= std_logic_vector(signed(addr_s) + signed(n_of_b_i));
		end if;
	end process;

	coeff_re_inst : entity work.fft_ram_coeff
	generic map ( DATA => DATA_SIZE, ADDR => ADDR_SIZE)
  	port map (clk_a => cpu_clk_i, clk_b => clk_i, reset => rst_i,
    	we_a => coeff_re_we_i, addr_a => coeff_re_addr_i, 
		din_a => coeff_re_i, dout_a => read_coeff_re_o,
    	we_b => '0', addr_b => addr_s, 
		din_b  => (others => '0'), dout_b => tmp_re_s);

	coeff_im_inst : entity work.fft_ram_coeff
	generic map ( DATA => DATA_SIZE, ADDR => ADDR_SIZE)
  	port map (clk_a => cpu_clk_i, clk_b => clk_i, reset => rst_i,
    	we_a => coeff_im_we_i, addr_a => coeff_im_addr_i, 
		din_a => coeff_im_i, dout_a => read_coeff_im_o,
    	we_b => '0', addr_b => addr_s,
		din_b  => (others => '0'), dout_b => tmp_im_s);

end architecture fft_coeff_handler_1;

