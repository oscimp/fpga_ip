---------------------------------------------------------------------------
-- (c) Copyright: OscillatorIMP Digital
-- Author : Gwenhael Goavec-Merou<gwenhael.goavec-merou@trabucayre.com>
-- Creation date : 2015/04/08
---------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

entity nco_counter is
	generic (
		id : natural := 1;
		RESET_ACCUM : boolean := false;
		DEFAULT_RST_ACCUM_VAL : natural := 25;
		DATA_SIZE : natural := 16;
		LUT_SIZE : natural := 10;
		COUNTER_SIZE : natural := 28;
		MAX_TRIG : natural := 3;
		-- Parameters of Axi Slave Bus Interface S00_AXI
		C_S00_AXI_DATA_WIDTH	: integer	:= 32;
		C_S00_AXI_ADDR_WIDTH	: integer	:= 5
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
		-- hardware pinc and poff
		sync_i : in std_logic := '0';
		pinc_i : in std_logic_vector(COUNTER_SIZE-1 downto 0) := (COUNTER_SIZE-1 downto 0 => '0');
		pinc_en_i : in std_logic := '0';
		pinc_rst_i : in std_logic := '0';
		pinc_clk_i : in std_logic := '0';
		poff_i : in std_logic_vector(LUT_SIZE-1 downto 0) := (LUT_SIZE-1 downto 0 => '0');
		poff_en_i : in std_logic := '0';
		poff_rst_i : in std_logic := '0';
		poff_clk_i : in std_logic := '0';
		-- output data bit3
		dds_cos_o : out std_logic_vector(DATA_SIZE-1 downto 0);
		dds_sin_o : out std_logic_vector(DATA_SIZE-1 downto 0);
		dds_en_o : out std_logic;
		dds_clk_o : out std_logic;
		dds_rst_o : out std_logic;
		saw_i_o : out std_logic_vector(DATA_SIZE-1 downto 0);
		saw_q_o : out std_logic_vector(DATA_SIZE-1 downto 0);
		saw_en_o : out std_logic;
		saw_clk_o : out std_logic;
		saw_rst_o : out std_logic;
		trigger_o : out std_logic;
		
		-- output single bit3
		cos_fake_o : out std_logic;
		sin_fake_o : out std_logic;
		wave_clk_o : out std_logic;
		wave_rst_o : out std_logic;
		wave_en_o : out std_logic
	);
end nco_counter;

architecture Behavioral of nco_counter is
	constant INTERNAL_ADDR_WIDTH : integer := 3;
	signal cpt_step_s, cpt_step_sync_s : std_logic_vector(COUNTER_SIZE-1 downto 0);
	signal cpt_step_mux_s 	: std_logic_vector(COUNTER_SIZE-1 downto 0);
	signal cpt_off_s, cpt_off_sync_s : std_logic_vector(LUT_SIZE-1 downto 0);
	signal cpt_off_mux_s 	: std_logic_vector(LUT_SIZE-1 downto 0);
	signal pinc_sw_s, pinc_sw_sync_s : std_logic;
	signal poff_sw_s, poff_sw_sync_s : std_logic;
	signal enable_s, enable_sync_s : std_logic;
	-- comm
	signal addr_s : std_logic_vector(INTERNAL_ADDR_WIDTH-1 downto 0);
	signal write_en_s, read_en_s : std_logic;
	signal wave_en_s : std_logic;
	signal step_scale_s : std_logic_vector(LUT_SIZE-1 downto 0);
	-- reset
	signal max_accum_s, max_accum_sync_s : std_logic_vector(COUNTER_SIZE-1 downto 0);
begin
	dds_rst_o <= ref_rst_i;
	wave_rst_o <= ref_rst_i;
	saw_rst_o <= ref_rst_i;
	dds_en_o <= wave_en_s;
	wave_en_o <= wave_en_s;
	saw_en_o <= wave_en_s;
	wave_clk_o <= ref_clk_i;
	dds_clk_o <= ref_clk_i;
	saw_clk_o <= ref_clk_i;
	
	nco_inst1 : entity work.nco_counter_logic
	generic map (
		RESET_ACCUM => RESET_ACCUM,
		COUNTER_SIZE => COUNTER_SIZE,
		LUT_SIZE => LUT_SIZE,
		DATA_SIZE => DATA_SIZE,
		MAX_TRIG => MAX_TRIG
	)
	port map(
		cpu_clk_i => s00_axi_aclk,
		clk_i => ref_clk_i,
		rst_i => ref_rst_i,
		--configuration (wishbone)
		sync_i => sync_i,
		max_accum_i => max_accum_sync_s,
		enable_i => enable_sync_s,
		cpt_inc_i => cpt_step_mux_s,
		cpt_off_i => cpt_off_mux_s,
		cos_o => dds_cos_o,
		sin_o => dds_sin_o,
		saw_i_o => saw_i_o,
		saw_q_o => saw_q_o,
		trigger_o => trigger_o,
		--step_scale_o => open, --step_scale_s,
		--output
		sin_fake_o => sin_fake_o,
		wave_en_o => wave_en_s,
		cos_fake_o => cos_fake_o
	);

	cpt_step_mux_s <= cpt_step_sync_s when pinc_sw_sync_s = '1' else
					pinc_i;
	cpt_off_mux_s <= cpt_off_sync_s when poff_sw_sync_s = '1' else
					poff_i;

	--- synchro ---
	pinc_syn : entity work.nco_counter_synchronizer_bit
	port map (ref_clk_i => s00_axi_aclk, clk_i => ref_clk_i,
		bit_i => pinc_sw_s, bit_o => pinc_sw_sync_s);
	poff_syn : entity work.nco_counter_synchronizer_bit
	port map (ref_clk_i => s00_axi_aclk, clk_i => ref_clk_i,
		bit_i => poff_sw_s, bit_o => poff_sw_sync_s);
	max_acc_syn : entity work.nco_counter_synchronizer_vector
	generic map (DATA => COUNTER_SIZE)
	port map (ref_clk_i => s00_axi_aclk, clk_i => ref_clk_i,
		bit_i => max_accum_s, bit_o => max_accum_sync_s);
	cpt_off_syn : entity work.nco_counter_synchronizer_vector
	generic map (DATA => LUT_SIZE)
	port map (ref_clk_i => s00_axi_aclk, clk_i => ref_clk_i,
		bit_i => cpt_off_s, bit_o => cpt_off_sync_s);
	cpt_step_syn : entity work.nco_counter_synchronizer_vector
	generic map (DATA => COUNTER_SIZE)
	port map (ref_clk_i => s00_axi_aclk, clk_i => ref_clk_i,
		bit_i => cpt_step_s, bit_o => cpt_step_sync_s);
	enable_syn : entity work.nco_counter_synchronizer_bit
	port map (ref_clk_i => s00_axi_aclk, clk_i => ref_clk_i,
		bit_i => enable_s, bit_o => enable_sync_s);
	---------------

	wb_nco_inst : entity work.wb_nco_counter
    generic map(
		COUNTER_SIZE => COUNTER_SIZE,
		LUT_SIZE => LUT_SIZE,
        id        => id,
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
		--reset_nco_o   => reset_nco_s,
		--step_scale_i => (LUT_SIZE-1 downto 0), --step_scale_s,
		max_accum_o => max_accum_s,
		pinc_sw_o => pinc_sw_s,
		poff_sw_o => poff_sw_s,
		enable_o => enable_s,
		cpt_off_o => cpt_off_s,
		cpt_step_o => cpt_step_s
    );

	-- Instantiation of Axi Bus Interface S00_AXI
	handle_comm : entity work.nco_counter_handcomm
	generic map (C_S_AXI_DATA_WIDTH	=> C_S00_AXI_DATA_WIDTH,
		C_S_AXI_ADDR_WIDTH	=> C_S00_AXI_ADDR_WIDTH,
		INTERNAL_ADDR_WIDTH => INTERNAL_ADDR_WIDTH) 
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
		addr_o => addr_s);
end Behavioral;
