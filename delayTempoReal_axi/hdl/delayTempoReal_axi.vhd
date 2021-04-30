library ieee;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;

entity delayTempoReal_axi is
	generic (
		DATA_SIZE : natural := 16;
		MAX_NB_DELAY : natural := 6;
		DEFAULT_DELAY : natural := 0;
		-- Parameters of Axi Slave Bus Interface S00_AXI
		C_S00_AXI_DATA_WIDTH	: integer	:= 32;
		C_S00_AXI_ADDR_WIDTH	: integer	:= 3
	);
	port (
		-- input data
		data_i			: in std_logic_vector(DATA_SIZE-1 downto 0);
		data_en_i		: in std_logic;
		data_eof_i		: in std_logic;
		data_clk_i		: in std_logic;
		data_rst_i		: in std_logic;
		-- output data
		data_o			: out std_logic_vector(DATA_SIZE-1 downto 0);
		data_en_o		: out std_logic;
		data_eof_o		: out std_logic;
		data_clk_o		: out std_logic;
		data_rst_o		: out std_logic;
		-- Ports of Axi Slave Bus Interface S00_AXI
		s00_axi_aclk	: in std_logic;
		s00_axi_reset	: in std_logic;
		s00_axi_awaddr	: in std_logic_vector(C_S00_AXI_ADDR_WIDTH-1 downto 0);
		s00_axi_awvalid	: in std_logic;
		s00_axi_awready	: out std_logic;
		s00_axi_wdata	: in std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
		s00_axi_wvalid	: in std_logic;
		s00_axi_wready	: out std_logic;
		s00_axi_bresp	: out std_logic_vector(1 downto 0);
		s00_axi_bvalid	: out std_logic;
		s00_axi_bready	: in std_logic;
		s00_axi_araddr	: in std_logic_vector(C_S00_AXI_ADDR_WIDTH-1 downto 0);
		s00_axi_arvalid	: in std_logic;
		s00_axi_arready	: out std_logic;
		s00_axi_rdata	: out std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
		s00_axi_rresp	: out std_logic_vector(1 downto 0);
		s00_axi_rvalid	: out std_logic;
		s00_axi_rready	: in std_logic
	);
end delayTempoReal_axi;

architecture arch_imp of delayTempoReal_axi is

	constant INTERNAL_ADDR_WIDTH : natural := 1;
	signal addr_s : std_logic_vector(INTERNAL_ADDR_WIDTH-1 downto 0);
	signal write_en_s, read_en_s : std_logic;

	constant DELAY_ADDR_SZ : natural := natural(ceil(log2(real(MAX_NB_DELAY))));
	signal delay_s, delay_sync_s : std_logic_vector(DELAY_ADDR_SZ-1 downto 0);

begin
	data_clk_o <= data_clk_i;
	data_rst_o <= data_rst_i;
	
	delay_logic_inst : entity work.delayTempoReal_axi_logic
	generic map (DELAY_SIZE => DELAY_ADDR_SZ, DATA_SIZE => DATA_SIZE)
	port map (clk_i => data_clk_i, rst_i => data_rst_i,
		delay_i => delay_sync_s,
		data_i => data_i, data_en_i => data_en_i, data_eof_i => data_eof_i,
		data_o => data_o, data_en_o => data_en_o, data_eof_o => data_eof_o
	);

	sync_delay_inst : entity work.delayTempoReal_axi_sync_slv
	generic map (DATA => DELAY_ADDR_SZ)
	port map (clk_i => data_clk_i, bit_i => delay_s,
		bit_o => delay_sync_s
	);

	-- Instantiation of Axi Bus Interface S00_AXI
	delayTempoReal_axi_comm_inst : entity work.delayTempoReal_axi_comm
	generic map (DEFAULT_DELAY => DEFAULT_DELAY,
		DELAY_ADDR_SZ => DELAY_ADDR_SZ,
		AXI_ADDR_WIDTH => INTERNAL_ADDR_WIDTH,
		C_S_AXI_DATA_WIDTH	=> C_S00_AXI_DATA_WIDTH
	)
	port map (clk_i => s00_axi_aclk, reset => s00_axi_reset,
		addr_i => addr_s,
		write_en_i => write_en_s, writedata => s00_axi_wdata,
		read_en_i => read_en_s, read_ack_o => s00_axi_rvalid,
		readdata => s00_axi_rdata,
		delay_o => delay_s
	);

	-- Instantiation of Axi Bus Interface S00_AXI
	handle_comm : entity work.delayTempoReal_axi_handCom
	generic map (
		C_S_AXI_DATA_WIDTH	=> C_S00_AXI_DATA_WIDTH,
		C_S_AXI_ADDR_WIDTH	=> C_S00_AXI_ADDR_WIDTH,
		INTERNAL_ADDR_WIDTH => INTERNAL_ADDR_WIDTH
	)
	port map (
		S_AXI_ACLK		=> s00_axi_aclk,
		S_AXI_RESET		=> s00_axi_reset,
		S_AXI_AWADDR	=> s00_axi_awaddr,
		S_AXI_AWVALID	=> s00_axi_awvalid,
		S_AXI_AWREADY	=> s00_axi_awready,
		S_AXI_WVALID	=> s00_axi_wvalid,
		S_AXI_WREADY	=> s00_axi_wready,
		S_AXI_BRESP		=> s00_axi_bresp,
		S_AXI_BVALID	=> s00_axi_bvalid,
		S_AXI_BREADY	=> s00_axi_bready,
		S_AXI_ARADDR	=> s00_axi_araddr,
		S_AXI_ARVALID	=> s00_axi_arvalid,
		S_AXI_ARREADY	=> s00_axi_arready,
		S_AXI_RRESP		=> s00_axi_rresp,
		S_AXI_RVALID	=> open,
		S_AXI_RREADY	=> s00_axi_rready,
		read_en_o		=> read_en_s,
		write_en_o		=> write_en_s,
		addr_o			=> addr_s
	);

end arch_imp;
