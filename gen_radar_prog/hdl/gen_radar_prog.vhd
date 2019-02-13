---------------------------------------------------------------------------
-- (c) Copyright: OscillatorIMP Digital
-- Author : Gwenhael Goavec-Merou<gwenhael.goavec-merou@trabucayre.com>
-- 2013-2018
---------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

entity gen_radar_prog is
	generic (
		ID : natural := 1;
		C_S00_AXI_DATA_WIDTH	: integer	:= 32;
		C_S00_AXI_ADDR_WIDTH	: integer	:= 4;
		--freq_in : natural := 200;  -- ADC clock rate en MHz
		DATA_SIZE : natural := 16;
		BURST_SIZE : natural := 1024;
		--RXOFF : natural := 20;   -- freq_in exprime' en MHz donc RXOFF/1000 sera en ns
		--TXON: natural := 80      -- idem
		RXOFF : natural := 2;   -- exprime' en cycle
		TXON: natural := 8      -- idem
	);
	port (
		-- Syscon signals
		switch_o	: out std_logic;
		switchn_o   : out std_logic;
		--processing
		data_i_i	: in std_logic_vector(DATA_SIZE-1 downto 0);
		data_q_i	: in std_logic_vector(DATA_SIZE-1 downto 0);
		data_en_i	: in std_logic;
		data_clk_i 	: in std_logic;
		data_rst_i 	: in std_logic;
		data_i_o	: out std_logic_vector(DATA_SIZE-1 downto 0);
		data_q_o	: out std_logic_vector(DATA_SIZE-1 downto 0);
		data_en_o	: out std_logic;
		data_clk_o 	: out std_logic;
		data_rst_o 	: out std_logic;
		data_eof_o	: out std_logic;
		-- axi
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
end gen_radar_prog;

architecture Behavioral of gen_radar_prog is
	-- comm
	signal rxoff_s, txon_s : std_logic_vector(15 downto 0);
	signal addr_s : std_logic_vector(1 downto 0);
	signal write_en_s, read_en_s : std_logic;
	signal point_period_s : std_logic_vector(15 downto 0);
begin
	data_clk_o <= data_clk_i;
	data_rst_o <= data_rst_i;

	gr_logic_inst : entity work.gen_radar_prog_logic
	generic map (
		DATA_SIZE => DATA_SIZE,
		BURST_SIZE => BURST_SIZE
	)
	port map(
		-- Syscon signals
		reset     	=> data_rst_i,
		clk       	=> data_clk_i,
		switch_o	=> switch_o,
		switchn_o   => switchn_o,
		-- axi
		rxoff_i		=> rxoff_s,
		txon_i 		=> txon_s,
		point_period_i => point_period_s,
		--processing
		data_i_i	=> data_i_i,
		data_q_i	=> data_q_i,
		data_en_i	=> data_en_i,
		data_i_o	=> data_i_o,
		data_q_o	=> data_q_o,
		data_en_o	=> data_en_o,
		data_eof_o	=> data_eof_o
	);


	wb_inst: Entity work.wb_gen_radar_prog
    generic map(
        id        => ID,
		RXOFF	=> RXOFF,
		TXON	=> TXON,
		NB_POINT  => BURST_SIZE,
		wb_size   => C_S00_AXI_DATA_WIDTH)
    port map (
		-- Syscon signals
		reset     => s00_axi_reset,
		clk       => s00_axi_aclk,
		-- Wishbone signals
		wbs_add       => addr_s,
		wbs_write     => write_en_s,
		wbs_writedata => s00_axi_wdata,
		wbs_read     => read_en_s,
		wbs_readdata  => s00_axi_rdata,
		rx_off_o	=> rxoff_s,
		tx_on_o		=> txon_s,
		point_period_o => point_period_s);

-- Instantiation of Axi Bus Interface S00_AXI
	handle_comm : entity work.gen_radar_prog_handComm
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

