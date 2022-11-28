library ieee;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;

entity firComplex is
	generic (
		-- Users to add parameters here
		ID : natural := 1;
		coeff_format : string := "signed";
		data_signed  : boolean := true;
		NB_COEFF : natural := 128;
		COEFF_SIZE : natural := 16;
		DECIMATE_FACTOR : natural := 10;
		DATA_IN_SIZE : natural := 16;
		DATA_OUT_SIZE: natural := 39;
		-- Parameters of Axi Slave Bus Interface S00_AXI
		C_S00_AXI_DATA_WIDTH	: integer	:= 32;
		C_S00_AXI_ADDR_WIDTH	: integer	:= 4
	);
	port (
		-- input data
		data_i_i : in std_logic_vector(DATA_IN_SIZE-1 downto 0);
		data_q_i : in std_logic_vector(DATA_IN_SIZE-1 downto 0);
		data_en_i: in std_logic;
		data_clk_i: in std_logic;
		data_rst_i: in std_logic;
		-- for the next component
		data_i_o  : out std_logic_vector(DATA_OUT_SIZE-1 downto 0);		
		data_q_o  : out std_logic_vector(DATA_OUT_SIZE-1 downto 0);
		data_en_o : out std_logic;
		data_clk_o : out std_logic;
		data_rst_o : out std_logic;
		-- ctrl
		tick_o : out std_logic;
		-- User ports ends
		-- Do not modify the ports beyond this line


		-- Ports of Axi Slave Bus Interface S00_AXI
		s00_axi_aclk	: in std_logic;
		s00_axi_reset	: in std_logic;
		s00_axi_awaddr	: in std_logic_vector(C_S00_AXI_ADDR_WIDTH-1 downto 0);
		--s00_axi_awprot	: in std_logic_vector(2 downto 0);
		s00_axi_awvalid	: in std_logic;
		s00_axi_awready	: out std_logic;
		s00_axi_wdata	: in std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
		--s00_axi_wstrb	: in std_logic_vector((C_S00_AXI_DATA_WIDTH/8)-1 downto 0);
		s00_axi_wvalid	: in std_logic;
		s00_axi_wready	: out std_logic;
		s00_axi_bresp	: out std_logic_vector(1 downto 0);
		s00_axi_bvalid	: out std_logic;
		s00_axi_bready	: in std_logic;
		s00_axi_araddr	: in std_logic_vector(C_S00_AXI_ADDR_WIDTH-1 downto 0);
		--s00_axi_arprot	: in std_logic_vector(2 downto 0);
		s00_axi_arvalid	: in std_logic;
		s00_axi_arready	: out std_logic;
		s00_axi_rdata	: out std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
		s00_axi_rresp	: out std_logic_vector(1 downto 0);
		s00_axi_rvalid	: out std_logic;
		s00_axi_rready	: in std_logic
	);
end firComplex;

architecture arch_imp of firComplex is
	constant COEFF_ADDR_SZ : natural := natural(ceil(log2(real(NB_COEFF))));
	signal coeff_en_s : std_logic;
    signal coeff_val_s : std_logic_vector(COEFF_SIZE-1 downto 0);
	signal coeff_read_s : std_logic_vector(COEFF_SIZE-1 downto 0);
    signal coeff_addr_s : std_logic_vector(COEFF_ADDR_SZ-1 downto 0);
	constant INTERNAL_ADDR_WIDTH : natural := 2;
	signal addr_s : std_logic_vector(1 downto 0);
	signal write_en_s, read_en_s : std_logic;

	signal data_en_s : std_logic;
begin
	tick_o <= data_en_s;
	data_en_o <= data_en_s;

	data_clk_o <= data_clk_i;
	data_rst_o <= data_rst_i;

	-- Instantiation of Axi Bus Interface S00_AXI
	firComplex_axi_inst : entity work.firComplex_axi
	generic map (ID=>ID, COEFF_SIZE => COEFF_SIZE,
		coeff_format => coeff_format,
		COEFF_ADDR_SZ => COEFF_ADDR_SZ,
		C_S_AXI_DATA_WIDTH	=> C_S00_AXI_DATA_WIDTH
	)
	port map (
		S_AXI_ACLK	=> s00_axi_aclk,
		reset	=> s00_axi_reset,

        addr_i => addr_s,
		write_en_i	=> write_en_s,
		writedata	=> s00_axi_wdata,
		read_en_i	=> read_en_s,
		read_ack_o	=> s00_axi_rvalid,
		readdata	=> s00_axi_rdata,
		-- end
		coeff_en_o => coeff_en_s,
        coeff_val_o => coeff_val_s,
        coeff_read_i => coeff_read_s,
        coeff_addr_o => coeff_addr_s
	);

	-- Add user logic here
	fir_top_inst : entity work.firComplex_top
	generic map (
		coeff_format => coeff_format,
		data_signed => data_signed,
		NB_COEFF => NB_COEFF,
		DECIMATE_FACTOR => DECIMATE_FACTOR,
		COEFF_SIZE => COEFF_SIZE,
		COEFF_ADDR_SZ => COEFF_ADDR_SZ,
		DATA_SIZE => DATA_IN_SIZE,
		DATA_OUT_SIZE => DATA_OUT_SIZE
	)
	port map (
		-- Syscon signals
		clk				=> data_clk_i,
		reset		 	=> data_rst_i,
		clk_axi 		=> s00_axi_aclk,
		--simulation
		wr_coeff_en_i 	=> coeff_en_s,
		wr_coeff_addr_i => coeff_addr_s,
		wr_coeff_val_i 	=> coeff_val_s,
		rd_coeff_val_o 	=> coeff_read_s,
		-- input data
		data_i_i => data_i_i,
		data_q_i => data_q_i,
		data_en_i => data_en_i,
		-- for the next component
		data_i_o	=> data_i_o,
		data_q_o	=> data_q_o,
		data_en_o	=> data_en_s
	);

-- Instantiation of Axi Bus Interface S00_AXI
handle_comm : entity work.firComplex_handCom
	generic map (
		C_S_AXI_DATA_WIDTH	=> C_S00_AXI_DATA_WIDTH,
		C_S_AXI_ADDR_WIDTH	=> C_S00_AXI_ADDR_WIDTH,
		INTERNAL_ADDR_WIDTH => INTERNAL_ADDR_WIDTH
	)
	port map (
		S_AXI_ACLK		=> s00_axi_aclk,
		S_AXI_RESET		=> s00_axi_reset,
		S_AXI_AWADDR	=> s00_axi_awaddr,
		--S_AXI_AWPROT	=> s00_axi_awprot,
		S_AXI_AWVALID	=> s00_axi_awvalid,
		S_AXI_AWREADY	=> s00_axi_awready,
		--S_AXI_WSTRB	=> s00_axi_wstrb,
		S_AXI_WVALID	=> s00_axi_wvalid,
		S_AXI_WREADY	=> s00_axi_wready,
		S_AXI_BRESP	=> s00_axi_bresp,
		S_AXI_BVALID	=> s00_axi_bvalid,
		S_AXI_BREADY	=> s00_axi_bready,
		S_AXI_ARADDR	=> s00_axi_araddr,
		--S_AXI_ARPROT	=> s00_axi_arprot,
		S_AXI_ARVALID	=> s00_axi_arvalid,
		S_AXI_ARREADY	=> s00_axi_arready,
		S_AXI_RRESP	=> s00_axi_rresp,
		S_AXI_RVALID	=> open,--s00_axi_rvalid,
		S_AXI_RREADY	=> s00_axi_rready,
		read_en_o => read_en_s,
		write_en_o => write_en_s,
		addr_o => addr_s
	);

end arch_imp;
