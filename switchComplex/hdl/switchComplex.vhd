library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

entity switchComplex is
	generic (
		ID : natural := 1;
		DEFAULT_INPUT : natural := 0;
		DATA_SIZE : natural := 16;
		C_S00_AXI_DATA_WIDTH	: integer	:= 32;
		C_S00_AXI_ADDR_WIDTH	: integer	:= 4
	);
	port (
		--processing
		data1_i_i	: in std_logic_vector(DATA_SIZE-1 downto 0);
		data1_q_i	: in std_logic_vector(DATA_SIZE-1 downto 0);
		data1_en_i	: in std_logic;
		data1_clk_i	: in std_logic;
		data1_eof_i	: in std_logic := '0';
		data1_rst_i	: in std_logic;

		data2_i_i	: in std_logic_vector(DATA_SIZE-1 downto 0);
		data2_q_i	: in std_logic_vector(DATA_SIZE-1 downto 0);
		data2_en_i	: in std_logic;
		data2_clk_i	: in std_logic;
		data2_eof_i	: in std_logic := '0';
		data2_rst_i	: in std_logic;

		data_i_o	: out std_logic_vector(DATA_SIZE-1 downto 0);
		data_q_o	: out std_logic_vector(DATA_SIZE-1 downto 0);
		data_en_o	: out std_logic;
		data_clk_o	: out std_logic;
		data_eof_o	: out std_logic;
		data_rst_o	: out std_logic;

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
end switchComplex;

architecture Behavioral of switchComplex is
	-- comm
	signal addr_s : std_logic_vector(1 downto 0);
	signal write_en_s, read_en_s : std_logic;
	signal witchIn : std_logic;
	signal witchIn_sync: std_logic;
begin

	data_i_o <= data1_i_i when witchIn_sync = '0' else data2_i_i;
	data_q_o <= data1_q_i when witchIn_sync = '0' else data2_q_i;
	data_en_o <= data1_en_i when witchIn_sync = '0' else data2_en_i;
	data_eof_o <= data1_eof_i when witchIn_sync = '0' else data2_eof_i;
	data_rst_o <= data1_rst_i;
	data_clk_o <= data1_clk_i;

	switch_sync : entity work.switchComplex_synch
	port map (ref_clk_i => s00_axi_aclk, clk_i => data1_clk_i,
		bit_i => witchIn, bit_o => witchIn_sync);

	switchComplexWb_inst : entity work.switchComplex_wb
    generic map(
        id        => id,
		DEFAULT_INPUT => DEFAULT_INPUT,
        wb_size   => C_S00_AXI_DATA_WIDTH -- Data port size for wishbone
    )
    port map(
		-- Syscon signals
		reset     => s00_axi_reset,
		clk       => s00_axi_aclk,
		-- Wishbone signals
		wbs_add       => addr_s,       
		wbs_write     => write_en_s,     
		wbs_writedata => s00_axi_wdata, 
		wbs_read     => read_en_s,     
		wbs_readdata  => s00_axi_rdata,  
		witchInput_o => witchIn
    );

	-- Instantiation of Axi Bus Interface S00_AXI
	handle_comm : entity work.switchComplex_handComm
	generic map (
		C_S_AXI_DATA_WIDTH	=> C_S00_AXI_DATA_WIDTH,
		C_S_AXI_ADDR_WIDTH	=> C_S00_AXI_ADDR_WIDTH
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
		S_AXI_RVALID	=> s00_axi_rvalid,
		S_AXI_RREADY	=> s00_axi_rready,
		read_en_o => read_en_s,
		write_en_o => write_en_s,
		addr_o => addr_s
	);
end Behavioral;

