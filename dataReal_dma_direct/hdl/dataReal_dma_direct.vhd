
-- currently only support up to 16bits per chan
-- and only one or two input
-- eof and sof are not supported
-- two inputs must be synchronize (ie dataX_en_i high at the same time
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

entity dataReal_dma_direct is
	generic (
		NB_INPUT                : natural := 2;
		NB_SAMPLE              : natural := 1024;
		SIGNED_FORMAT          : boolean := true;
		DATA_SIZE              : natural := 16;
		USE_SOF                : boolean := false;
		STOP_ON_EOF            : boolean := false;
		-- Parameters of Axi Slave Bus Interface S00_AXI
		C_S00_AXI_DATA_WIDTH   : integer := 32;
		C_S00_AXI_ADDR_WIDTH   : integer := 4;
		-- Parameters of Axi Master Bus Interface M00_AXIS
		C_M00_AXIS_TDATA_WIDTH : integer := 32
	);
	port (
		-- chan1
		data1_i     : in std_logic_vector(DATA_SIZE-1 downto 0);
		data1_en_i  : in std_logic;
		data1_sof_i : in std_logic := '0';
		data1_eof_i : in std_logic := '0';
		data1_clk_i : in std_logic;
		data1_rst_i : in std_logic;
		-- chan2
		data2_i     : in std_logic_vector(DATA_SIZE-1 downto 0) := (DATA_SIZE-1 downto 0 => '0');
		data2_en_i  : in std_logic := '0';
		data2_sof_i : in std_logic := '0';
		data2_eof_i : in std_logic := '0';
		data2_clk_i : in std_logic := '0';
		data2_rst_i : in std_logic := '0';
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
end dataReal_dma_direct;

architecture Behavioral of dataReal_dma_direct is
	function getIntNbSample(nb_input, data_size, nb_sample: natural) return natural is
	begin
		if (nb_input = 1 and data_size <= 16) then
			return nb_sample/2;
		end if;
		return nb_sample;
	end function getIntNbSample;
	constant INT_NB_SAMPLE : natural := getIntNbSample(NB_INPUT, DATA_SIZE, NB_SAMPLE);
	function getIntNbInput(nb_input, data_size: natural) return natural is
	begin
		if (nb_input = 2) then
			if (data_size <= 16) then
				return 1;
			else
				return 2;
			end if;
		end if;
		return 1;
	end function getIntNbInput;
	constant INT_NB_INPUT : natural := getIntNbInput(NB_INPUT, DATA_SIZE);
	function getIntSize(data_size: natural) return natural is
	begin
		if (data_size <= 16) then
			return 16;
		end if;
		return 32;
	end function getIntSize;
	constant INT_DATA_SIZE : natural := getIntSize(DATA_SIZE);
	--axi
	signal addr_s : std_logic_vector(1 downto 0);
	signal write_en_s, read_en_s : std_logic;

	-- new
	signal data1_s : std_logic_vector(INT_DATA_SIZE-1 downto 0);
	signal data2_s : std_logic_vector(INT_DATA_SIZE-1 downto 0);
	signal data1_d1_s  : std_logic_vector(31 downto 0);
	signal data2_d1_s  : std_logic_vector(31 downto 0);
	signal data_en_s: std_logic;
	signal seq_pos_s: std_logic;

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

	same_size: if DATA_SIZE = INT_DATA_SIZE generate
		data1_s <= data1_i;
		data2_s <= data2_i;
	end generate same_size;
	diff_size_gen: if DATA_SIZE < INT_DATA_SIZE generate
		signed_data_gen: if SIGNED_FORMAT = true generate
			data1_s <= 
				(INT_DATA_SIZE-1 downto DATA_SIZE => data1_i(DATA_SIZE-1)) & data1_i;
			data2_s <= 
				(INT_DATA_SIZE-1 downto DATA_SIZE => data2_i(DATA_SIZE-1)) & data2_i;
		end generate signed_data_gen;
		unsigned_data_gen: if SIGNED_FORMAT = false generate
			data1_s <= 
				(INT_DATA_SIZE-1 downto DATA_SIZE => '0') & data1_i;
			data2_s <= 
				(INT_DATA_SIZE-1 downto DATA_SIZE => '0') & data2_i;
		end generate unsigned_data_gen;
	end generate diff_size_gen;

	-- when two input => just concat data1 and data2
	-- and send directly to the axistream generator
	twoIn: if (NB_INPUT = 2) generate
		data_en_s <= data1_en_i and data2_en_i;
		twoSixteen: if (INT_DATA_SIZE = 16) generate
			data1_d1_s <= data2_s & data1_s;
			data2_d1_s <= (others => '0');
		end generate twoSixteen;
		twoThirtyTwo: if (INT_DATA_SIZE = 32) generate
			data1_d1_s <= data1_s;
			data2_d1_s <= data2_s;
		end generate twoThirtyTwo;
	end generate twoIn;

	-- when only one input => need to wait 2 consecutive
	-- data to have a 32bit word before sending to the
	-- axistream generator
	oneIn: if (NB_INPUT = 1) generate
		data2_d1_s <= (others => '0');
		oneSixteen: if (INT_DATA_SIZE = 16) generate
			process(data1_clk_i) begin
				if rising_edge(data1_clk_i) then
					if data1_rst_i = '1' then
						data1_d1_s <= (others => '0');
						seq_pos_s <= '0';
					elsif data1_en_i = '1' then
						seq_pos_s <= not seq_pos_s;
						if seq_pos_s = '0' then
							data1_d1_s <= data1_d1_s(31 downto 16) & data1_s;
						else
							data1_d1_s <= data1_s & data1_d1_s(15 downto 0);
						end if;
					end if;
					if data1_rst_i = '1' then
						data_en_s <= '0';
					elsif (seq_pos_s and data1_en_i) = '1' then
						data_en_s <= '1';
					else
						data_en_s <= '0';
					end if;
				end if;
			end process;
		end generate oneSixteen;
		oneThirtyTwo: if (INT_DATA_SIZE = 32) generate
			data1_d1_s <= data1_s;
		end generate oneThirtyTwo;
	end generate oneIn;

	-- Instantiation of Axi Bus Interface M00_AXIS
	dma_flow_slave_axis_inst : entity work.axi_dataReal_dma_direct
	generic map (
		NB_INPUT  => INT_NB_INPUT,
		DATA_SIZE => 32,
		NB_SAMPLE => INT_NB_SAMPLE,
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
		data_en_i => data_en_s,
		data_sof_i => data_sof_s,
		data_eof_i => data_eof_s,
		data1_i => data1_d1_s,
		data2_i => data2_d1_s
	);

	busy_sync : entity work.dataReal_dma_direct_sync
	port map (clk_i => s00_axi_aclk,
		bit_i => busy_s, bit_o => busy_sync_s);	
	start_sync : entity work.dataReal_dma_direct_sync
	port map (clk_i => data1_clk_i,
		bit_i => start_acquisition_s, bit_o => start_acquisition_sync_s);	

	wb_inst : entity work.wb_dataReal_dma_direct
	generic map(
		NB_SAMPLE => INT_NB_SAMPLE,
		NB_INPUT => INT_NB_INPUT,
		--STOP_ON_EOF => STOP_ON_EOF,
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
	handle_comm : entity work.dataReal_dma_direct_handCom
	generic map (
		C_S_AXI_DATA_WIDTH	=> C_S00_AXI_DATA_WIDTH,
		C_S_AXI_ADDR_WIDTH	=> C_S00_AXI_ADDR_WIDTH,
		INTERNAL_ADDR_WIDTH => 2
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

