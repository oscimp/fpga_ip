library ieee;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.all;

entity fft is
	generic (
		-- Users to add parameters here
		USE_EOF	: boolean := false;
		USE_FIRST_BUFF : boolean := true;
		USE_SEC_BUFF : boolean := true;
		LOG_2_N_FFT : natural := 11;
		--COEFF_SIZE : natural := 16;
		SHIFT_VAL : natural := 16;
		DATA_SIZE : natural := 32;
		DATA_IN_SIZE : natural := 16;
		-- Parameters of Axi Slave Bus Interface S00_AXI
		C_S00_AXI_DATA_WIDTH	: integer	:= 32;
		C_S00_AXI_ADDR_WIDTH	: integer	:= 4
	);
	port (
		test_o : out std_logic;
		test_eof_o : out std_logic;
		-- input data
		data_i : in std_logic_vector(DATA_IN_SIZE-1 downto 0);
		data_en_i: in std_logic;
		data_eof_i: in std_logic;
		data_clk_i: in std_logic;
		data_rst_i: in std_logic;
		-- for the next component
		data_re_o  : out std_logic_vector(DATA_SIZE-1 downto 0);
		data_im_o  : out std_logic_vector(DATA_SIZE-1 downto 0);		
		data_en_o : out std_logic;
		data_eof_o : out std_logic;
		data_clk_o : out std_logic;
		data_rst_o : out std_logic;
		-- User ports ends
		-- Do not modify the ports beyond this line


		-- Ports of Axi Slave Bus Interface S00_AXI
		s00_axi_aclk	: in std_logic;
		s00_axi_reset	: in std_logic;
		s00_axi_awaddr	: in std_logic_vector(C_S00_AXI_ADDR_WIDTH-1 downto 0);
		s00_axi_awprot	: in std_logic_vector(2 downto 0);
		s00_axi_awvalid	: in std_logic;
		s00_axi_awready	: out std_logic;
		s00_axi_wdata	: in std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
		s00_axi_wstrb	: in std_logic_vector((C_S00_AXI_DATA_WIDTH/8)-1 downto 0);
		s00_axi_wvalid	: in std_logic;
		s00_axi_wready	: out std_logic;
		s00_axi_bresp	: out std_logic_vector(1 downto 0);
		s00_axi_bvalid	: out std_logic;
		s00_axi_bready	: in std_logic;
		s00_axi_araddr	: in std_logic_vector(C_S00_AXI_ADDR_WIDTH-1 downto 0);
		s00_axi_arprot	: in std_logic_vector(2 downto 0);
		s00_axi_arvalid	: in std_logic;
		s00_axi_arready	: out std_logic;
		s00_axi_rdata	: out std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
		s00_axi_rresp	: out std_logic_vector(1 downto 0);
		s00_axi_rvalid	: out std_logic;
		s00_axi_rready	: in std_logic
	);
end fft;

architecture arch_imp of fft is
    constant COEFF_SIZE : natural := SHIFT_VAL + 2;
	signal coeff_re_en_s, coeff_im_en_s : std_logic;
    signal coeff_re_val_s, coeff_im_val_s : std_logic_vector(COEFF_SIZE-1 downto 0);
    signal coeff_re_addr_s, coeff_im_addr_s : std_logic_vector(LOG_2_N_FFT-1 downto 0);
	signal addr_s : std_logic_vector(1 downto 0);
	signal write_en_s, read_en_s : std_logic;
	signal read_coeff_re_s : std_logic_vector(COEFF_SIZE-1 downto 0);
	signal read_coeff_im_s : std_logic_vector(COEFF_SIZE-1 downto 0);
	signal test_data_s : std_logic_vector(31 downto 0);
	signal test_data_addr_s : std_logic_vector(LOG_2_N_FFT-1 downto 0);
	signal rcp_data_s : std_logic_vector(31 downto 0);
	signal rcp_data_addr_s : std_logic_vector(LOG_2_N_FFT-1 downto 0);
	signal data_eof_s : std_logic;
	signal data_en_s : std_logic;
begin

	data_clk_o <= data_clk_i;
	data_rst_o <= data_rst_i;

	-- Instantiation of Axi Bus Interface S00_AXI
	fft_axi_inst : entity work.fft_axi
	generic map (COEFF_SIZE => COEFF_SIZE,
		ADDR_SIZE => LOG_2_N_FFT,
		C_S_AXI_DATA_WIDTH	=> C_S00_AXI_DATA_WIDTH
	)
	port map (
		S_AXI_ACLK	=> s00_axi_aclk,
		reset	=> s00_axi_reset,
		data_i => test_data_s,
		data_addr_o => test_data_addr_s,

        addr_i => addr_s,
		write_en_i	=> write_en_s,
		writedata	=> s00_axi_wdata,
		read_en_i	=> read_en_s,
		read_ack_o	=> s00_axi_rvalid,
		readdata	=> s00_axi_rdata,
		read_coeff_re_i => read_coeff_re_s,
		read_coeff_im_i => read_coeff_im_s,
		coeff_re_en_o => coeff_re_en_s,
		coeff_im_en_o => coeff_im_en_s,
        coeff_re_val_o => coeff_re_val_s,
        coeff_im_val_o => coeff_im_val_s,
        coeff_re_addr_o => coeff_re_addr_s,
        coeff_im_addr_o => coeff_im_addr_s
	);

	-- Add user logic here
	fir_top_inst : entity work.fft_top_logic
	generic map (
		USE_EOF => USE_EOF,
		USE_FIRST_BUFF => USE_FIRST_BUFF,
		USE_SEC_BUFF => USE_SEC_BUFF,
		LOG_2_N_FFT => LOG_2_N_FFT,
		N_FFT => 2**LOG_2_N_FFT,
		COEFF_SIZE => COEFF_SIZE,
		SHIFT_VAL => SHIFT_VAL,
		ADDR_SIZE => LOG_2_N_FFT,
		DATA_SIZE => DATA_SIZE,
		DATA_IN_SIZE => DATA_IN_SIZE
	)
	port map (
		-- Syscon signals
		clk_i		=> data_clk_i,
		cpu_clk_i	=> s00_axi_aclk,
		cpu_rst_i 	=> s00_axi_reset,
		data_rst_i	=> data_rst_i,
		-- input data
		data_i => data_i,
		data_en_i => data_en_i,
		data_eof_i => data_eof_i,
		--configuration
		read_coeff_re_o => read_coeff_re_s,
		read_coeff_im_o => read_coeff_im_s,
		coeff_re_i => coeff_re_val_s,
		coeff_re_addr_i => coeff_re_addr_s,
		coeff_re_en_i => coeff_re_en_s,
		coeff_im_i => coeff_im_val_s,
		coeff_im_addr_i => coeff_im_addr_s,
		coeff_im_en_i => coeff_im_en_s,
		-- results
		res_re_o	=> data_re_o,
		res_im_o	=> data_im_o,
		res_eof_o   => data_eof_s,
		res_en_o	=> data_en_s
	);
	data_eof_o <= data_eof_s;
	data_en_o <= data_en_s;
	test_eof_o <= data_eof_s;
	test_o <= data_en_s;

-- Instantiation of Axi Bus Interface S00_AXI
handle_comm : entity work.fft_handCom
	generic map (
		C_S_AXI_DATA_WIDTH	=> C_S00_AXI_DATA_WIDTH,
		C_S_AXI_ADDR_WIDTH	=> C_S00_AXI_ADDR_WIDTH
	)
	port map (
		S_AXI_ACLK		=> s00_axi_aclk,
		S_AXI_RESET		=> s00_axi_reset,
		S_AXI_AWADDR	=> s00_axi_awaddr,
		S_AXI_AWPROT	=> s00_axi_awprot,
		S_AXI_AWVALID	=> s00_axi_awvalid,
		S_AXI_AWREADY	=> s00_axi_awready,
		S_AXI_WSTRB	=> s00_axi_wstrb,
		S_AXI_WVALID	=> s00_axi_wvalid,
		S_AXI_WREADY	=> s00_axi_wready,
		S_AXI_BRESP	=> s00_axi_bresp,
		S_AXI_BVALID	=> s00_axi_bvalid,
		S_AXI_BREADY	=> s00_axi_bready,
		S_AXI_ARADDR	=> s00_axi_araddr,
		S_AXI_ARPROT	=> s00_axi_arprot,
		S_AXI_ARVALID	=> s00_axi_arvalid,
		S_AXI_ARREADY	=> s00_axi_arready,
		S_AXI_RRESP	=> s00_axi_rresp,
		S_AXI_RVALID	=> open,--s00_axi_rvalid,
		S_AXI_RREADY	=> s00_axi_rready,
		read_en_o => read_en_s,
		write_en_o => write_en_s,
		addr_o => addr_s
	);


	process(data_clk_i)
	begin
		if rising_edge(data_clk_i) then
			if data_rst_i = '1' then
				rcp_data_addr_s <= (others => '0');
			else
				rcp_data_addr_s <= rcp_data_addr_s;
				if data_en_i = '1' then
					rcp_data_addr_s <= std_logic_vector(
						unsigned(rcp_data_addr_s) + 1);
				end if;
			end if;
		end if;
	end process;
	rcp_data_s <= (31 downto DATA_IN_SIZE => data_i(DATA_IN_SIZE-1))
		& data_i;

	coeff_re_inst : entity work.fft_ram_coeff
	generic map ( DATA => 32, ADDR => LOG_2_N_FFT)
  	port map (clk_a => data_clk_i, clk_b => s00_axi_aclk, 
		reset => s00_axi_reset,
    	we_a => data_en_i, addr_a => rcp_data_addr_s, 
		din_a => rcp_data_s, dout_a => open,
    	we_b => '0', addr_b => test_data_addr_s, 
		din_b  => (others => '0'), dout_b => test_data_s);

end arch_imp;
