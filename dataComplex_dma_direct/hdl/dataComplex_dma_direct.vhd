library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

entity dataComplex_dma_direct is
	generic (
		NB_SAMPLE : natural := 1024;
		SIGNED_FORMAT : boolean := true;
		DATA_SIZE : natural := 16;
		USE_SOF   : boolean := false;
		STOP_ON_EOF: boolean := false;
		-- Parameters of Axi Slave Bus Interface S00_AXI
		C_S00_AXI_DATA_WIDTH	: integer	:= 32;
		C_S00_AXI_ADDR_WIDTH	: integer	:= 7;
		-- Parameters of Axi Master Bus Interface M00_AXIS
		C_M00_AXIS_TDATA_WIDTH  : integer   := 32
	);
	port (
		-- chan1
		data1_i_i : in std_logic_vector(DATA_SIZE-1 downto 0);
		data1_q_i : in std_logic_vector(DATA_SIZE-1 downto 0);
		data1_en_i : in std_logic;
		data1_sof_i : in std_logic := '0';
		data1_eof_i : in std_logic := '0';
		data1_clk_i : in std_logic;
		data1_rst_i : in std_logic;
		-- chan2
		data2_i_i : in std_logic_vector(DATA_SIZE-1 downto 0);
		data2_q_i : in std_logic_vector(DATA_SIZE-1 downto 0);
		data2_en_i : in std_logic;
		data2_sof_i : in std_logic := '0';
		data2_eof_i : in std_logic := '0';
		data2_clk_i : in std_logic;
		data2_rst_i : in std_logic;
		-- Ports of Axi Master Bus Interface M00_AXIS
		m00_axis_aclk   : in std_logic;
		m00_axis_reset  : in std_logic;
		m00_axis_tvalid : out std_logic;
		m00_axis_tdata  : out std_logic_vector(C_M00_AXIS_TDATA_WIDTH-1 downto 0);
		m00_axis_tstrb  : out std_logic_vector((C_M00_AXIS_TDATA_WIDTH/8)-1 downto 0);
		m00_axis_tlast  : out std_logic;
		m00_axis_tready : in std_logic;
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
end dataComplex_dma_direct;

architecture Behavioral of dataComplex_dma_direct is
	--axi
	signal addr_s : std_logic_vector(3 downto 0);
	signal write_en_s, read_en_s : std_logic;

	-- new
	signal data1_s : std_logic_vector(31 downto 0);
	signal data2_s : std_logic_vector(31 downto 0);

	signal data_sof_s : std_logic;
	signal data_eof_s : std_logic;

	-- axi4lite -> axis
	signal start_acquisition_s      : std_logic;
	signal start_acquisition_sync_s : std_logic;
	-- axis -> axi4lite
	signal busy_s, busy_sync_s      : std_logic;

begin
	-- note sure at all maybe better to handle
	-- in axistream part
	stop_eof_gen: if STOP_ON_EOF = true generate
		data_eof_s <= data1_sof_i;
	end generate;
	not_eof_gen: if STOP_ON_EOF = false generate
		data_eof_s <= '0';
	end generate;
	-- ok
	use_sof_gen: if USE_SOF = true generate
		data_sof_s <= data1_sof_i;
	end generate use_sof_gen;
	not_sof_gen: if USE_SOF = false generate
		data_sof_s <= '1';
	end generate not_sof_gen;

	same_size: if DATA_SIZE = 16 generate
		data1_s <= data1_q_i & data1_i_i;
		data2_s <= data2_q_i & data2_i_i;
	end generate same_size;
	diff_size_gen: if DATA_SIZE < 16 generate
		signed_data_gen: if SIGNED_FORMAT = true generate
			data1_s <= 
				(15 downto DATA_SIZE => data1_q_i(DATA_SIZE-1)) & data1_q_i &
				(15 downto DATA_SIZE => data1_i_i(DATA_SIZE-1)) & data1_i_i;
			data2_s <= 
				(15 downto DATA_SIZE => data2_q_i(DATA_SIZE-1)) & data2_q_i &
				(15 downto DATA_SIZE => data2_i_i(DATA_SIZE-1)) & data2_i_i;
		end generate signed_data_gen;
		unsigned_data_gen: if SIGNED_FORMAT = false generate
			data1_s <= 
				(15 downto DATA_SIZE => '0') & data1_q_i &
				(15 downto DATA_SIZE => '0') & data1_i_i;
			data2_s <= 
				(15 downto DATA_SIZE => '0') & data2_q_i &
				(15 downto DATA_SIZE => '0') & data2_i_i;
		end generate unsigned_data_gen;
	end generate diff_size_gen;

	-- Instantiation of Axi Bus Interface M00_AXIS
	dma_flow_slave_axis_inst : entity work.axi_dataComplex_dma_direct
	generic map (
		DATA_SIZE => 32,
		NB_SAMPLE => NB_SAMPLE,
		C_M_AXIS_TDATA_WIDTH	=> C_M00_AXIS_TDATA_WIDTH
	)
	port map (
		reset => data1_rst_i,
		clk => data1_clk_i,

		M_AXIS_TVALID   => m00_axis_tvalid,
		M_AXIS_TDATA	=> m00_axis_tdata,
		M_AXIS_TSTRB	=> m00_axis_tstrb,
		M_AXIS_TLAST	=> m00_axis_tlast,
		M_AXIS_TREADY   => m00_axis_tready,

		start_acquisition_i => start_acquisition_sync_s,
		busy_o => busy_s,
		data_en_i => data1_en_i,
		data_sof_i => data1_sof_i,
		data_eof_i => data1_eof_i,
		data1_i => data1_s,
		data2_i => data2_s
	);

	busy_sync : entity work.dataComplex_dma_direct_sync
	port map (clk_i => s00_axi_aclk,
		bit_i => busy_s, bit_o => busy_sync_s);	
	start_sync : entity work.dataComplex_dma_direct_sync
	port map (clk_i => data1_clk_i,
		bit_i => start_acquisition_s, bit_o => start_acquisition_sync_s);	

	wb_inst : entity work.wb_dataComplex_dma_direct
	generic map(
		NB_SAMPLE => NB_SAMPLE,
		wb_size   => C_S00_AXI_DATA_WIDTH
	)
	port map (
		-- Syscon signals
		reset	 => s00_axi_reset,
		clk		=> s00_axi_aclk,
		-- Wishbone signals
		wbs_add       => addr_s,
		wbs_writedata => s00_axi_wdata,
		wbs_readdata  => s00_axi_rdata,
		wbs_read      => read_en_s,
		wbs_read_ack  => s00_axi_rvalid,
		wbs_write     => write_en_s,
		--data 
		busy_i        => busy_sync_s,
		start_o       => start_acquisition_s
	);

	-- Instantiation of Axi Bus Interface S00_AXI
	handle_comm : entity work.dataComplex_dma_direct_handCom
	generic map (
		C_S_AXI_DATA_WIDTH	=> C_S00_AXI_DATA_WIDTH,
		C_S_AXI_ADDR_WIDTH	=> C_S00_AXI_ADDR_WIDTH,
		ADDR_WIDTH_OUT => 4
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

end Behavioral;

