library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

Entity fft_data_handler is 
	generic (
		ADDR_SIZE : natural := 10;
		DATA_SIZE : natural := 16
	);
	port (
		-- Syscon signals
		clk_i		: in std_logic;
		rst_i		: in std_logic;
		-- control
		s_of_b_i	: in std_logic_vector(ADDR_SIZE-1 downto 0);
		-- data from first stage
		fs_data_en_i : in std_logic;
		fs_data_re_i  : in std_logic_vector(DATA_SIZE-1 downto 0);
		fs_data_im_i  : in std_logic_vector(DATA_SIZE-1 downto 0);
		fs_data_addr_i : in std_logic_vector(ADDR_SIZE-1 downto 0);
		-- data for compute
		cmp_start_i : in std_logic;

		cmp_data_a_re_o  : out std_logic_vector(DATA_SIZE-1 downto 0);
		cmp_data_a_im_o  : out std_logic_vector(DATA_SIZE-1 downto 0);
		cmp_a_addr_i : in std_logic_vector(ADDR_SIZE-1 downto 0);
		cmp_data_b_re_o  : out std_logic_vector(DATA_SIZE-1 downto 0);
		cmp_data_b_im_o  : out std_logic_vector(DATA_SIZE-1 downto 0);
		cmp_b_addr_i : in std_logic_vector(ADDR_SIZE-1 downto 0);
		cmp_data_en_o : out std_logic;
		-- data from compute
		cplx_data_a_re_i  : in std_logic_vector(DATA_SIZE-1 downto 0);
		cplx_data_a_im_i  : in std_logic_vector(DATA_SIZE-1 downto 0);
		cplx_data_b_re_i  : in std_logic_vector(DATA_SIZE-1 downto 0);
		cplx_data_b_im_i  : in std_logic_vector(DATA_SIZE-1 downto 0);
		cplx_addr_a_i : in std_logic_vector(ADDR_SIZE-1 downto 0);
		cplx_addr_b_i : in std_logic_vector(ADDR_SIZE-1 downto 0);
		cplx_data_en_i : in std_logic;
		-- read to regen data flow
		res_re_o  : out std_logic_vector(DATA_SIZE-1 downto 0);
		res_im_o  : out std_logic_vector(DATA_SIZE-1 downto 0);
		res_addr_i : in std_logic_vector(ADDR_SIZE-1 downto 0)
	);
end entity;
Architecture fft_data_handler_1 of fft_data_handler is
	type state_type is (IDLE, READ_FIRST);
	signal state_s : state_type;
	signal tmp_data_a_re_s, tmp_data_a_im_s : std_logic_vector(DATA_SIZE-1 downto 0);
	signal tmp_data_b_re_s, tmp_data_b_im_s : std_logic_vector(DATA_SIZE-1 downto 0);
	signal cmp_data_a_re_s : std_logic_vector(DATA_SIZE-1 downto 0);
	signal cmp_data_a_im_s : std_logic_vector(DATA_SIZE-1 downto 0);
	signal cmp_data_b_re_s : std_logic_vector(DATA_SIZE-1 downto 0);
	signal cmp_data_b_im_s : std_logic_vector(DATA_SIZE-1 downto 0);

	-- ram mux
	signal port_b_addr_s, port_a_addr_s : std_logic_vector(ADDR_SIZE-1 downto 0);
	signal port_a_data_re_s : std_logic_vector(DATA_SIZE-1 downto 0);
	signal port_a_data_re_out_s : std_logic_vector(DATA_SIZE-1 downto 0);
	signal port_a_data_im_s : std_logic_vector(DATA_SIZE-1 downto 0);
	signal port_a_data_im_out_s : std_logic_vector(DATA_SIZE-1 downto 0);
	signal port_b_data_re_s : std_logic_vector(DATA_SIZE-1 downto 0);
	signal port_b_data_re_out_s : std_logic_vector(DATA_SIZE-1 downto 0);
	signal port_b_data_im_s : std_logic_vector(DATA_SIZE-1 downto 0);
	signal port_b_data_im_out_s : std_logic_vector(DATA_SIZE-1 downto 0);
	signal we_en_s : std_logic;
	signal pa_select_s, pb_select_s : std_logic_vector(1 downto 0);
begin
	cmp_data_a_re_o <= cmp_data_a_re_s;
	cmp_data_a_im_o <= cmp_data_a_im_s;
	cmp_data_b_re_o <= cmp_data_b_re_s;
	cmp_data_b_im_o <= cmp_data_b_im_s;
	
	res_re_o <= port_b_data_re_out_s;
	res_im_o <= port_b_data_im_out_s;

	process(clk_i, rst_i)
	begin
		if rst_i = '1' then
			cmp_data_en_o <= '0';
			cmp_data_a_re_s <= (others => '0');
			cmp_data_a_im_s <= (others => '0');
			cmp_data_b_re_s <= (others => '0');
			cmp_data_b_im_s <= (others => '0');
		elsif rising_edge(clk_i) then
			cmp_data_en_o <= '0';
			cmp_data_a_re_s <= cmp_data_a_re_s;
			cmp_data_a_im_s <= cmp_data_a_im_s;
			cmp_data_b_re_s <= cmp_data_b_re_s;
			cmp_data_b_im_s <= cmp_data_b_im_s;
			case state_s is
			when IDLE =>
				if cmp_start_i = '1' then
					state_s <= READ_FIRST;
				end if;
			when READ_FIRST =>
				cmp_data_a_re_s <= port_a_data_re_out_s;
				cmp_data_a_im_s <= port_a_data_im_out_s;
				cmp_data_b_re_s <= port_b_data_re_out_s;
				cmp_data_b_im_s <= port_b_data_im_out_s;
				cmp_data_en_o <= '1';
				state_s <= IDLE;
			end case;
		end if;
	end process;

	-- handle write from input
	--		  write from complex
	--		  read from this block
	pa_select_s <= fs_data_en_i&cplx_data_en_i;
	porta_mux : process(pa_select_s,
		cplx_addr_a_i, cplx_data_a_re_i, cplx_data_a_im_i,
		fs_data_addr_i, fs_data_re_i, fs_data_im_i,
		cmp_a_addr_i)
	begin
		case (pa_select_s) is
		when "01" => -- write from input
			port_a_addr_s <= cplx_addr_a_i;
			port_a_data_re_s <= cplx_data_a_re_i;
			port_a_data_im_s <= cplx_data_a_im_i;
		when "10" => -- write from complex
			port_a_addr_s <= fs_data_addr_i;
			port_a_data_re_s <= fs_data_re_i;
			port_a_data_im_s <= fs_data_im_i;
		when others => -- read from this block
			port_a_addr_s <= cmp_a_addr_i;
			port_a_data_re_s <= (others => '0');
			port_a_data_im_s <= (others => '0');
		end case;
	end process porta_mux;
	we_en_s <= fs_data_en_i or cplx_data_en_i;

	-- handle read for output
	--		  write from complex
	--		  read from this block
	pb_select_s <= cplx_data_en_i&cmp_start_i;
	portb_mux : process(pb_select_s,
		cmp_b_addr_i, res_addr_i,
		cplx_addr_b_i, cplx_data_b_re_i, cplx_data_b_im_i)
	begin
		case (pb_select_s) is
		when "01" => -- read from this block
			port_b_addr_s <= cmp_b_addr_i;
			port_b_data_re_s <= (others => '0');
			port_b_data_im_s <= (others => '0');
		when "10" => -- write from complex
			port_b_addr_s <= cplx_addr_b_i;
			port_b_data_re_s <= cplx_data_b_re_i;
			port_b_data_im_s <= cplx_data_b_im_i;
		when others =>
			port_b_addr_s <= res_addr_i;
			port_b_data_re_s <= (others => '0');
			port_b_data_im_s <= (others => '0');
		end case;
	end process portb_mux;

	ram_re_dat_inst : entity work.fft_ram
	generic map ( DATA => DATA_SIZE, ADDR => ADDR_SIZE)
  	port map (clk_a => clk_i, clk_b => clk_i, reset => rst_i,
    	we_a => we_en_s, addr_a => port_a_addr_s,
    	din_a  => port_a_data_re_s, dout_a => port_a_data_re_out_s,
    	we_b => cplx_data_en_i, addr_b => port_b_addr_s,
		din_b => port_b_data_re_s, dout_b => port_b_data_re_out_s);

	ram_im_dat_inst : entity work.fft_ram
	generic map ( DATA => DATA_SIZE, ADDR => ADDR_SIZE)
  	port map (clk_a => clk_i, clk_b => clk_i, reset => rst_i,
    	we_a => we_en_s, addr_a => port_a_addr_s,
    	din_a  => port_a_data_im_s, dout_a => port_a_data_im_out_s,
    	we_b => cplx_data_en_i, addr_b => port_b_addr_s,
		din_b => port_b_data_im_s, dout_b => port_b_data_im_out_s);

end architecture fft_data_handler_1;

