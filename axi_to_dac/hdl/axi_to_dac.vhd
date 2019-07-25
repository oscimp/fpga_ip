library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

entity axi_to_dac is
	generic (
		DATA_SIZE            : natural := 14;
		DATAA_DEFAULT_OUT    : integer := 0;
		DATAA_EN_ALWAYS_HIGH : boolean := false;
		DATAB_DEFAULT_OUT    : integer := 0;
		DATAB_EN_ALWAYS_HIGH : boolean := false;
		SYNCHRONIZE_CHAN     : boolean := false;
		id : natural := 1;
		-- Parameters of Axi Slave Bus Interface S00_AXI
		C_S00_AXI_DATA_WIDTH  : integer	:= 32;
		C_S00_AXI_ADDR_WIDTH  : integer	:= 4
	);
	port (
		-- Syscon signals
		ref_clk_i : in std_logic;
		ref_rst_i : in std_logic;
		-- Wishbone signals
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
		s00_axi_rready	: in std_logic;
		-- output
		dataA_o	 : out std_logic_vector(DATA_SIZE-1 downto 0);
		dataA_en_o  : out std_logic;
		dataA_eof_o : out std_logic;
		dataA_clk_o : out std_logic;
		dataA_rst_o : out std_logic;
		dataB_o     : out std_logic_vector(DATA_SIZE-1 downto 0);
		dataB_en_o	: out std_logic;
		dataB_eof_o : out std_logic;
		dataB_clk_o : out std_logic;
		dataB_rst_o : out std_logic
	);
end axi_to_dac;

architecture Behavioral of axi_to_dac is
	signal data_a_en_always_high_s      : std_logic;
	signal data_a_en_always_high_sync_s : std_logic;
	signal data_b_en_always_high_s      : std_logic;
	signal data_b_en_always_high_sync_s : std_logic;
	signal synchronize_chan_s           : std_logic;
	signal synchronize_chan_sync_s      : std_logic;
	signal data_a_s      : std_logic_vector(DATA_SIZE-1 downto 0);
	signal data_a_sync_s : std_logic_vector(DATA_SIZE-1 downto 0);
	signal data_a_out_s  : std_logic_vector(DATA_SIZE-1 downto 0);
	signal data_a_en_s      : std_logic;
	signal data_a_en_sync_s : std_logic;
	signal data_a_en_next_s : std_logic;
	signal data_b_s      : std_logic_vector(DATA_SIZE-1 downto 0);
	signal data_b_sync_s : std_logic_vector(DATA_SIZE-1 downto 0);
	signal data_b_out_s  : std_logic_vector(DATA_SIZE-1 downto 0);
	signal data_b_en_s      : std_logic;
	signal data_b_en_sync_s : std_logic;
	-- comm
	signal addr_s : std_logic_vector(1 downto 0);
	signal write_en_s, read_en_s : std_logic;
begin
	dataA_o <= data_a_out_s;
	dataA_eof_o <= '0';
	dataA_clk_o <= ref_clk_i;
	dataA_rst_o <= ref_rst_i;
	dataB_o <= data_b_out_s;
	dataB_eof_o <= '0';
	dataB_clk_o <= ref_clk_i;
	dataB_rst_o <= ref_rst_i;

	data_a_en_next_s <= (data_a_en_sync_s and not synchronize_chan_sync_s) or
						(data_b_en_sync_s and synchronize_chan_sync_s);

	process(ref_clk_i)
	begin
		if rising_edge(ref_clk_i) then
			if ref_rst_i = '1' then
				data_a_out_s <= std_logic_vector(to_signed(DATAA_DEFAULT_OUT, DATA_SIZE));
				dataA_en_o <= '0';
			elsif data_a_en_next_s = '1' then
				data_a_out_s <= data_a_sync_s;
				dataA_en_o <= '1';
			else
				data_a_out_s <= data_a_out_s;
				dataA_en_o <= data_a_en_always_high_sync_s;
			end if;
			
			if ref_rst_i = '1' then
				data_b_out_s <= std_logic_vector(to_signed(DATAB_DEFAULT_OUT, DATA_SIZE));
				dataB_en_o <= '0';
			elsif data_b_en_sync_s = '1' then
				data_b_out_s <= data_b_sync_s;
				dataB_en_o <= '1';
			else
				data_b_out_s <= data_b_out_s;
				dataB_en_o <= data_b_en_always_high_sync_s;
			end if;
		end if;
	end process;

	dataA_sync: entity work.axi_to_dac_sync_vect
	generic map (DATA => DATA_SIZE)
	port map (ref_clk_i => s00_axi_aclk, clk_i => ref_clk_i,
		bit_i => data_a_s, bit_o => data_a_sync_s);
	dataB_sync: entity work.axi_to_dac_sync_vect
	generic map (DATA => DATA_SIZE)
	port map (ref_clk_i => s00_axi_aclk, clk_i => ref_clk_i,
		bit_i => data_b_s, bit_o => data_b_sync_s);
	conf_sync: entity work.axi_to_dac_sync_vect
	generic map (DATA => 5)
	port map (ref_clk_i => s00_axi_aclk, clk_i => ref_clk_i,
		bit_i => data_a_en_s & data_b_en_s 
				& data_a_en_always_high_s 
				& data_b_en_always_high_s & synchronize_chan_s,
		bit_o(4) => data_a_en_sync_s, bit_o(3) => data_b_en_sync_s,
		bit_o(2) => data_a_en_always_high_sync_s,
		bit_o(1) => data_b_en_always_high_sync_s,
		bit_o(0) => synchronize_chan_sync_s);

	wb_atd_inst : entity work.wb_axi_to_dac
    generic map(
        id        => id, DATA_SIZE => DATA_SIZE,
		DATA_A_EN_ALWAYS_HIGH => DATAA_EN_ALWAYS_HIGH,
		DATA_B_EN_ALWAYS_HIGH => DATAB_EN_ALWAYS_HIGH,
		SYNCHRONIZE_CHAN   => SYNCHRONIZE_CHAN,
        BUS_SIZE  => C_S00_AXI_DATA_WIDTH -- Data port size for wishbone
    )
    port map(
		-- Syscon signals
		reset     => s00_axi_reset,
		clk       => s00_axi_aclk,
		-- comm signals
		addr_i        => addr_s,
		wbs_write     => write_en_s,
		wbs_writedata => s00_axi_wdata,
		wbs_read     => read_en_s,
		wbs_readdata  => s00_axi_rdata,
		-- config
		data_a_en_always_high_o => data_a_en_always_high_s,
		data_b_en_always_high_o => data_b_en_always_high_s,
		synchronize_chan_o => synchronize_chan_s,
		-- data
		data_a_o => data_a_s,
		data_a_en_o => data_a_en_s,
		data_b_o => data_b_s,
		data_b_en_o => data_b_en_s
    );

	-- Instantiation of Axi Bus Interface S00_AXI
	handle_comm : entity work.axi_to_dac_handcomm
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

