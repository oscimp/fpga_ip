library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

entity windowReal is
	generic (
		DATA_SIZE : natural := 32;
		COEFF_ADDR_SIZE : natural := 8;
		COEFF_SIZE : natural := 16;
		id : natural := 1;
		-- Parameters of Axi Slave Bus Interface S00_AXI
		C_S00_AXI_DATA_WIDTH	: integer	:= 32;
		C_S00_AXI_ADDR_WIDTH	: integer	:= 4
	);
	port (
		s00_axi_aclk	: in std_logic;
		s00_axi_reset	: in std_logic;
		-- Wishbone signals
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
		s00_axi_rready	: in std_logic;
		data_en_i : in std_logic;
		data_clk_i : in std_logic;
		data_rst_i : in std_logic;
		data_i : in std_logic_vector(DATA_SIZE-1 downto 0);
		data_en_o : out std_logic;
		data_eof_o : out std_logic;
		data_clk_o : out std_logic;
		data_rst_o : out std_logic;
		data_o : out std_logic_vector(DATA_SIZE-1 downto 0)
	);
end windowReal;

architecture Behavioral of windowReal is
	signal coeff_en_s : std_logic;
	signal coeff_s : std_logic_vector(COEFF_SIZE downto 0);
	signal coeff_addr_s : std_logic_vector(COEFF_ADDR_SIZE-1 downto 0);
	-- comm
	signal addr_s : std_logic_vector(1 downto 0);
	signal write_en_s, read_en_s : std_logic;
begin
	data_clk_o <= data_clk_i;
	data_rst_o <= data_rst_i;

	windowRealLogic : entity work.windowReal_logic
	generic map (DATA_SIZE => DATA_SIZE, COEFF_SIZE => COEFF_SIZE+1,
		SHIFT=>COEFF_SIZE,
		COEFF_ADDR_SIZE => COEFF_ADDR_SIZE)
	port map (clk_i => data_clk_i,  cpu_clk_i => s00_axi_aclk,
		reset => data_rst_i,
		coeff_en_i => coeff_en_s, coeff_i => coeff_s, coeff_addr_i => coeff_addr_s,
		data_en_i => data_en_i, data_i => data_i,
		data_en_o => data_en_o, data_eof_o => data_eof_o, data_o => data_o);

	wb_windowReal_inst : entity work.wb_windowReal
    generic map(id => id, wb_size   => C_S00_AXI_DATA_WIDTH,
		COEFF_ADDR_SIZE => COEFF_ADDR_SIZE, COEFF_SIZE => COEFF_SIZE+1)
    port map(reset => s00_axi_reset, clk => s00_axi_aclk,
		wbs_add       => addr_s,       
		wbs_write     => write_en_s,     
		wbs_writedata => s00_axi_wdata, 
		wbs_read     => read_en_s,     
		wbs_readdata  => s00_axi_rdata,  
		coeff_en_o => coeff_en_s,
		coeff_addr_o => coeff_addr_s,
		coeff_o => coeff_s);

	windowRealHandComm: entity work.windowReal_handComm
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
		S_AXI_RVALID	=> s00_axi_rvalid,
		S_AXI_RREADY	=> s00_axi_rready,
		read_en_o => read_en_s,
		write_en_o => write_en_s,
		addr_o => addr_s
	);
end Behavioral;

