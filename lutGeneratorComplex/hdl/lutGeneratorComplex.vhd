-- Copyright 2023 Gwenhael Goavec-Merou
-- gwenhael.goavec-merou@trabucayre.com
--
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;
use IEEE.math_real.all;

entity lutGeneratorComplex is
	generic (
		RAM_DEPTH            : natural := 1024; --! ram depth
		DATA_SIZE            : natural := 16;   --! size of samples stored into the RAM
		PRESCALER_MAX        : natural := 12;   --! max value the prescaler is able to count
		-- Parameters of Axi Slave Bus Interface S00_AXI
		C_S00_AXI_DATA_WIDTH : integer := 32;
		C_S00_AXI_ADDR_WIDTH : integer := 5
	);
	port (
		s00_axi_aclk	: in  std_logic; --! AXI clock
		s00_axi_reset	: in  std_logic; --! AXI reset
		--! AXI slave interface
		s00_axi_awaddr	: in  std_logic_vector(C_S00_AXI_ADDR_WIDTH-1 downto 0);
		s00_axi_awprot	: in  std_logic_vector(2 downto 0);
		s00_axi_awvalid	: in  std_logic;
		s00_axi_awready	: out std_logic;
		s00_axi_wdata	: in  std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
		s00_axi_wstrb	: in  std_logic_vector((C_S00_AXI_DATA_WIDTH/8)-1 downto 0);
		s00_axi_wvalid	: in  std_logic;
		s00_axi_wready	: out std_logic;
		s00_axi_bresp	: out std_logic_vector(1 downto 0);
		s00_axi_bvalid	: out std_logic;
		s00_axi_bready	: in  std_logic;
		s00_axi_araddr	: in  std_logic_vector(C_S00_AXI_ADDR_WIDTH-1 downto 0);
		s00_axi_arprot	: in  std_logic_vector(2 downto 0);
		s00_axi_arvalid	: in  std_logic;
		s00_axi_arready	: out std_logic;
		s00_axi_rdata	: out std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
		s00_axi_rresp	: out std_logic_vector(1 downto 0);
		s00_axi_rvalid	: out std_logic;
		s00_axi_rready	: in  std_logic;
		-- ref CANDR
		ref_clk_i       : in  std_logic; --! reference clock (used for prescaler and generator)
		ref_rst_i       : in  std_logic; --! reference reset (used for prescaler and generator)
		data_clk_o      : out std_logic; --! output clock (same domain as stream)
		data_rst_o      : out std_logic; --! output reset (same domain as stream)
		data_en_o       : out std_logic; --! output sample is valid
		data_eof_o      : out std_logic; --! end sample before restart reading RAM
		data_sof_o      : out std_logic; --! first sample in the sequence
		data_i_o        : out std_logic_vector(DATA_SIZE-1 downto 0); --! in phase sample
		data_q_o        : out std_logic_vector(DATA_SIZE-1 downto 0)  --! quadrature sample
	);
end lutGeneratorComplex;

architecture Behavioral of lutGeneratorComplex is
	constant ADDR_SIZE                     : natural := natural(ceil(log2(real(RAM_DEPTH))));
	constant PRESCALER_SIZE                : natural := natural(ceil(log2(real(PRESCALER_MAX))));
	--! RAM configuration
	signal data_i_s, data_q_s              : std_logic_vector(DATA_SIZE-1 downto 0);
	signal data_addr_i_s, data_addr_q_s    : std_logic_vector(ADDR_SIZE-1 downto 0);
	signal data_en_i_s, data_en_q_s        : std_logic;
	--! enable/disable generator
	signal enable_s, enable_sync_s         : std_logic;
	--! prescaler value
	signal prescaler_s, prescaler_sync_s   : std_logic_vector(PRESCALER_SIZE-1 downto 0);
	--! number of samples to read before reseting RAM counter
	signal ram_length_s, ram_length_sync_s : std_logic_vector(ADDR_SIZE-1 downto 0);
	--! comm axi
	constant ADDR_WIDTH_AXI                : natural := 3;
	signal addr_s                          : std_logic_vector(ADDR_WIDTH_AXI-1 downto 0);
	signal write_en_s, read_en_s           : std_logic;
begin
	data_clk_o <= ref_clk_i;
	data_rst_o <= ref_rst_i;

	pseudoGenRealLogic : entity work.lutGeneratorComplex_logic
	generic map (DATA_SIZE => DATA_SIZE, ADDR_SIZE => ADDR_SIZE, PRESC_SIZE => PRESCALER_SIZE)
	port map (clk => ref_clk_i, reset => ref_rst_i, cpu_clk => s00_axi_aclk,
		data_en_i_i => data_en_i_s, data_adr_i_i => data_addr_i_s, data_i_i => data_i_s,
		data_en_q_i => data_en_q_s, data_adr_q_i => data_addr_q_s, data_q_i => data_q_s,
		prescaler_i => prescaler_sync_s, enable_i => enable_sync_s, ram_length_i => ram_length_sync_s,
		data_en_o => data_en_o, data_eof_o => data_eof_o, data_sof_o => data_sof_o,
		data_i_o => data_i_o, data_q_o => data_q_o
	);

	-- change domain AXI -> ref CANDR
	prescNenable: entity work.lutGeneratorComplex_sync_vect
	generic map (DATA => PRESCALER_SIZE+1)
	port map (ref_clk_i => s00_axi_aclk, clk_i => ref_clk_i,
		bit_i(PRESCALER_SIZE-1 downto 0) => prescaler_s, bit_i(PRESCALER_SIZE) => enable_s,
		bit_o(PRESCALER_SIZE-1 downto 0) => prescaler_sync_s, bit_o(PRESCALER_SIZE) => enable_sync_s
	);
	ramLength: entity work.lutGeneratorComplex_sync_vect
	generic map (DATA => ADDR_SIZE)
	port map (ref_clk_i => s00_axi_aclk, clk_i => ref_clk_i,
		bit_i => ram_length_s, bit_o => ram_length_sync_s
	);

	wb_pseudoGenReal_inst : entity work.wb_lutGeneratorComplex
    generic map(PRESC_SIZE => PRESCALER_SIZE, wb_size => C_S00_AXI_DATA_WIDTH,
		DATA_SIZE => DATA_SIZE, ADDR_SIZE => ADDR_SIZE)
    port map(reset => s00_axi_reset, clk => s00_axi_aclk,
		addr_i => addr_s,       
		wen_i => write_en_s, wrdata_i => s00_axi_wdata, 
		ren_i => read_en_s, rddata_o => s00_axi_rdata,
		data_en_i_o => data_en_i_s, data_i_o => data_i_s, data_addr_i_o => data_addr_i_s, 
		data_en_q_o => data_en_q_s, data_q_o => data_q_s, data_addr_q_o => data_addr_q_s, 
		enable_o => enable_s, ram_length_o => ram_length_s, prescaler_o => prescaler_s
	);

	pseudoGenRealHandComm: entity work.lutGeneratorComplex_handComm
	generic map (
		C_S_AXI_DATA_WIDTH	=> C_S00_AXI_DATA_WIDTH,
		C_S_AXI_ADDR_WIDTH	=> C_S00_AXI_ADDR_WIDTH,
		INTERNAL_ADDR_WIDTH => ADDR_WIDTH_AXI
	)
	port map (
		S_AXI_ACLK    => s00_axi_aclk,
		S_AXI_RESET   => s00_axi_reset,
		S_AXI_AWADDR  => s00_axi_awaddr,
		S_AXI_AWVALID => s00_axi_awvalid,
		S_AXI_AWREADY => s00_axi_awready,
		S_AXI_WVALID  => s00_axi_wvalid,
		S_AXI_WREADY  => s00_axi_wready,
		S_AXI_BVALID  => s00_axi_bvalid,
		S_AXI_BREADY  => s00_axi_bready,
		S_AXI_BRESP   => s00_axi_bresp,
		S_AXI_ARADDR  => s00_axi_araddr,
		S_AXI_ARVALID => s00_axi_arvalid,
		S_AXI_ARREADY => s00_axi_arready,
		S_AXI_RRESP   => s00_axi_rresp,
		S_AXI_RVALID  => s00_axi_rvalid,
		S_AXI_RREADY  => s00_axi_rready,
		read_en_o     => read_en_s,
		write_en_o    => write_en_s,
		addr_o        => addr_s
	);
end Behavioral;

