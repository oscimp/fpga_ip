---------------------------------------------------------------------------
-- (c) Copyright: OscillatorIMP Digital
-- Author : Gwenhael Goavec-Merou<gwenhael.goavec-merou@trabucayre.com>
-- 2013-2018
---------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

entity syncTrigStream is
	generic (
		C_S00_AXI_DATA_WIDTH	: integer	:= 32;
		C_S00_AXI_ADDR_WIDTH	: integer	:= 4;
		USE_EXT_TRIG: boolean := false;
		DFLT_PERIOD : natural := 300000000; -- 3s@100MHz
		DFLT_DUTY   : natural := 100;       -- 1us@100MHz
		GEN_SIZE    : natural := 32;
		DATA_SIZE   : natural := 16;
		NB_SAMPLE   : natural := 1024
	);
	port (
		-- Syscon signals
		pulse_o  	: out std_logic;
		ext_trig_i  : in std_logic;
		-- input
		data1_i_i	: in std_logic_vector(DATA_SIZE-1 downto 0);
		data1_q_i	: in std_logic_vector(DATA_SIZE-1 downto 0);
		data1_en_i	: in std_logic;
		data1_clk_i	: in std_logic;
		data1_rst_i	: in std_logic;
		data2_i_i	: in std_logic_vector(DATA_SIZE-1 downto 0);
		data2_q_i	: in std_logic_vector(DATA_SIZE-1 downto 0);
		data2_en_i	: in std_logic;
		data2_clk_i	: in std_logic;
		data2_rst_i	: in std_logic;
		-- output
		data1_i_o	: out std_logic_vector(DATA_SIZE-1 downto 0);
		data1_q_o	: out std_logic_vector(DATA_SIZE-1 downto 0);
		data1_en_o	: out std_logic;
		data1_clk_o	: out std_logic;
		data1_rst_o	: out std_logic;
		data1_eof_o	: out std_logic;
		data1_sof_o	: out std_logic;
		data2_i_o	: out std_logic_vector(DATA_SIZE-1 downto 0);
		data2_q_o	: out std_logic_vector(DATA_SIZE-1 downto 0);
		data2_en_o	: out std_logic;
		data2_clk_o	: out std_logic;
		data2_rst_o	: out std_logic;
		data2_eof_o	: out std_logic;
		data2_sof_o	: out std_logic;
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
end syncTrigStream;

architecture Behavioral of syncTrigStream is
	-- comm
	signal addr_s : std_logic_vector(1 downto 0);
	signal write_en_s, read_en_s : std_logic;
	signal period_cnt_s : std_logic_vector(GEN_SIZE-1 downto 0);
	signal period_cnt_sync_s : std_logic_vector(GEN_SIZE-1 downto 0);
	signal duty_cnt_s   : std_logic_vector(GEN_SIZE-1 downto 0);
	signal duty_cnt_sync_s   : std_logic_vector(GEN_SIZE-1 downto 0);
	signal enable_s, enable_sync_s : std_logic;

	signal data_en_s, data_eof_s, data_sof_s : std_logic;
begin
	data1_clk_o <= data1_clk_i;
	data1_rst_o <= data1_rst_i;
	data2_clk_o <= data2_clk_i;
	data2_rst_o <= data2_rst_i;

	gr_logic_inst : entity work.syncTrigStream_logic
	generic map (
		USE_EXT_TRIG => USE_EXT_TRIG,
		GEN_SIZE => GEN_SIZE,
		DATA_SIZE => DATA_SIZE,
		NB_SAMPLE => NB_SAMPLE
	)
	port map(
		-- Syscon signals
		reset     	=> data1_rst_i,
		clk       	=> data1_clk_i,
		-- pulse
		ext_trig_i  => ext_trig_i,
		pulse_o     => pulse_o,
		-- configuration
		period_cnt_i => period_cnt_sync_s,
		duty_cnt_i  => duty_cnt_sync_s,
		enable_i    => enable_sync_s,
		-- input
		data_en_i	=> data1_en_i,
		data1_i_i	=> data1_i_i,
		data1_q_i	=> data1_q_i,
		data2_i_i	=> data2_i_i,
		data2_q_i	=> data2_q_i,
		-- output
		data1_i_o	=> data1_i_o,
		data1_q_o	=> data1_q_o,
		data2_i_o	=> data2_i_o,
		data2_q_o	=> data2_q_o,
		data_en_o	=> data_en_s,
		data_sof_o	=> data_sof_s,
		data_eof_o	=> data_eof_s
	);
	data1_en_o <= data_en_s;
	data1_sof_o <= data_sof_s;
	data1_eof_o <= data_eof_s;
	data2_en_o <= data_en_s;
	data2_sof_o <= data_sof_s;
	data2_eof_o <= data_eof_s;

	sync_period : entity work.syncTrigStream_sync_vector
	generic map (DATA => GEN_SIZE)
	port map (ref_clk_i => s00_axi_aclk, clk_i => data1_clk_i,
			bit_i => period_cnt_s, bit_o => period_cnt_sync_s
	);
	sync_duty : entity work.syncTrigStream_sync_vector
	generic map (DATA => GEN_SIZE)
	port map (ref_clk_i => s00_axi_aclk, clk_i => data1_clk_i,
			bit_i => duty_cnt_s, bit_o => duty_cnt_sync_s
	);
	sync_en : entity work.syncTrigStream_sync_bit
	port map (ref_clk_i => s00_axi_aclk, clk_i => data1_clk_i,
			bit_i => enable_s, bit_o => enable_sync_s
	);


	wb_inst: Entity work.syncTrigStream_comm
    generic map(
		DFLT_PERIOD => DFLT_PERIOD,
		DFLT_DUTY => DFLT_DUTY,
		GEN_SIZE => GEN_SIZE,
		bus_size   => C_S00_AXI_DATA_WIDTH)
    port map (
		-- Syscon signals
		reset     => s00_axi_reset,
		clk       => s00_axi_aclk,
		-- Wishbone signals
		addr_i       => addr_s,
		wr_en_i      => write_en_s,
		writedata_i  => s00_axi_wdata,
		rd_en_i      => read_en_s,
		readdata_o   => s00_axi_rdata,
		enable_o     => enable_s,
		period_cnt_o =>  period_cnt_s,
		duty_cnt_o   =>  duty_cnt_s
	);

-- Instantiation of Axi Bus Interface S00_AXI
	handle_comm : entity work.syncTrigStream_handComm
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

