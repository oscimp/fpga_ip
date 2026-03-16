---------------------------------------------------------------------------
-- (c) Copyright: OscillatorIMP Digital
-- Author : Gwenhael Goavec-Merou<gwenhael.goavec-merou@trabucayre.com>
-- Creation date : 2019/04/20
---------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

Entity pid_velocity_axi is 
	generic (
		C_S00_AXI_DATA_WIDTH : integer := 32;
		C_S00_AXI_ADDR_WIDTH : integer := 5;
		P_SIZE : integer := 14;
		PSR : integer := 12; --PSR_SIZE
		I_SIZE : integer := 14;
		ISR : integer := 28;
		D_SIZE : integer := 14;
		DSR : integer := 8;
		DATA_IN_SIZE : natural := 14;
		DATA_OUT_SIZE : natural := 14
	);
	port (
		-- block signals
		data_i	 	: in std_logic_vector(DATA_IN_SIZE-1 downto 0);
		data_en_i	: in std_logic;
		data_clk_i 	: in std_logic;
		data_rst_i 	: in std_logic;
        setpoint_i  : in std_logic_vector(DATA_IN_SIZE-1 downto 0) := (DATA_IN_SIZE-1 downto 0 => '0');
        kp_i        : in std_logic_vector(P_SIZE-1 downto 0) := (P_SIZE-1 downto 0 => '0');
        ki_i        : in std_logic_vector(I_SIZE-1 downto 0) := (I_SIZE-1 downto 0 => '0');
        kd_i        : in std_logic_vector(D_SIZE-1 downto 0) := (D_SIZE-1 downto 0 => '0');
        sign_i      : in std_logic := '0';
        int_rst_i   : in std_logic := '0';
		data_o   	: out std_logic_vector(DATA_OUT_SIZE-1 downto 0);
		data_en_o	: out std_logic;
		data_clk_o 	: out std_logic;
		data_rst_o 	: out std_logic;
		  -- AXI signals
		s00_axi_aclk : in std_logic;
		s00_axi_reset : in std_logic;
		s00_axi_awaddr : in std_logic_vector(C_S00_AXI_ADDR_WIDTH-1 downto 0);
		s00_axi_awprot : in std_logic_vector(2 downto 0);
		s00_axi_awvalid : in std_logic;
		s00_axi_awready : out std_logic;
		s00_axi_wdata : in std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
		s00_axi_wstrb : in std_logic_vector((C_S00_AXI_DATA_WIDTH/8)-1 downto 0);
		s00_axi_wvalid : in std_logic;
		s00_axi_wready : out std_logic;
		s00_axi_bresp : out std_logic_vector(1 downto 0);
		s00_axi_bvalid : out std_logic;
		s00_axi_bready : in std_logic;
		s00_axi_araddr : in std_logic_vector(C_S00_AXI_ADDR_WIDTH-1 downto 0);
		s00_axi_arprot : in std_logic_vector(2 downto 0);
		s00_axi_arvalid : in std_logic;
		s00_axi_arready : out std_logic;
		s00_axi_rdata : out std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
		s00_axi_rresp : out std_logic_vector(1 downto 0);
		s00_axi_rvalid : out std_logic;
		s00_axi_rready : in std_logic
	);
end pid_velocity_axi;

Architecture Behavioral of pid_velocity_axi is
	signal setpoint_s : std_logic_vector(DATA_IN_SIZE-1 downto 0);
	signal setpoint2_s: std_logic_vector(DATA_IN_SIZE-1 downto 0);
	signal setpoint_sync_s : std_logic_vector(DATA_IN_SIZE-1 downto 0);
	signal kp_s,kp2_s : std_logic_vector(P_SIZE-1 downto 0);
	signal kp_sync_s  : std_logic_vector(P_SIZE-1 downto 0);
	signal ki_s,ki2_s : std_logic_vector(I_SIZE-1 downto 0);
	signal ki_sync_s  : std_logic_vector(I_SIZE-1 downto 0);
	signal kd_s,kd2_s : std_logic_vector(D_SIZE-1 downto 0);
	signal kd_sync_s  : std_logic_vector(D_SIZE-1 downto 0);
	signal sign_s     : std_logic;
	signal sign2_s    : std_logic;
	signal sign_sync_s: std_logic;
	signal int_rst_s  : std_logic;
	signal int_rst2_s : std_logic;
	signal int_rst_sync_s : std_logic;
	signal is_input_s : std_logic_vector(5 downto 0);
	signal is_input_sync_s : std_logic_vector(5 downto 0);
	--comm
	constant INTERNAL_ADDR_WIDTH : integer := 3;
	signal addr_s : std_logic_vector(INTERNAL_ADDR_WIDTH-1 downto 0);
	signal write_en_s, read_en_s : std_logic;
begin
	data_clk_o <= data_clk_i;
	data_rst_o <= data_rst_i;
	
	
	pid_velocity_axiLogic : entity work.pid_velocity_axi_logic
	generic map(DATA_IN_SIZE => DATA_IN_SIZE, DATA_OUT_SIZE => DATA_OUT_SIZE,
	P_SIZE => P_SIZE, I_SIZE => I_SIZE, D_SIZE => D_SIZE,
	ISR => ISR, PSR => PSR, DSR => DSR)
	port map (clk_i => data_clk_i, reset => data_rst_i,
		data_i => data_i, data_en_i  => data_en_i,
		data_o => data_o, data_en_o=> data_en_o,
		setpoint_i => setpoint2_s, 
		kp_i => kp2_s, ki_i => ki2_s, kd_i => kd2_s,
		sign_i => sign2_s, int_rst_i => int_rst2_s
	);

	setpoint2_s <= setpoint_sync_s when is_input_sync_s(0) = '1'
				else setpoint_i;
	kp2_s <= kp_sync_s when is_input_sync_s(1) = '1'
				else kp_i;
	ki2_s <= ki_sync_s when is_input_sync_s(2) = '1'
				else ki_i;
	kd2_s <= kd_sync_s when is_input_sync_s(3) = '1'
				else kd_i;
	sign2_s <= sign_sync_s when is_input_sync_s(4) = '1'
				else sign_i;
	int_rst2_s <= int_rst_sync_s when is_input_sync_s(5) = '1'
				else int_rst_i;

	septpoint_syn : entity work.pid_velocity_axi_sync_vector
	generic map (DATA => DATA_IN_SIZE)
	port map (ref_clk_i => s00_axi_aclk, clk_i => data_clk_i,
		bit_i => setpoint_s, bit_o => setpoint_sync_s);
	kp_syn : entity work.pid_velocity_axi_sync_vector
	generic map (DATA => P_SIZE)
	port map (ref_clk_i => s00_axi_aclk, clk_i => data_clk_i,
		bit_i => kp_s, bit_o => kp_sync_s);
	ki_syn : entity work.pid_velocity_axi_sync_vector
	generic map (DATA => I_SIZE)
	port map (ref_clk_i => s00_axi_aclk, clk_i => data_clk_i,
		bit_i => ki_s, bit_o => ki_sync_s);
	kd_syn : entity work.pid_velocity_axi_sync_vector
	generic map (DATA => D_SIZE)
	port map (ref_clk_i => s00_axi_aclk, clk_i => data_clk_i,
		bit_i => kd_s, bit_o => kd_sync_s);
	input_syn : entity work.pid_velocity_axi_sync_vector
	generic map (DATA => 6)
	port map (ref_clk_i => s00_axi_aclk, clk_i => data_clk_i,
		bit_i => is_input_s, bit_o => is_input_sync_s);

	sign_syn : entity work.pid_velocity_axi_sync_bit
	port map (ref_clk_i => s00_axi_aclk, clk_i => data_clk_i,
		bit_i => sign_s, bit_o => sign_sync_s);
	int_rst_syn : entity work.pid_velocity_axi_sync_bit
	port map (ref_clk_i => s00_axi_aclk, clk_i => data_clk_i,
		bit_i => int_rst_s, bit_o => int_rst_sync_s);
	---------------

	comm_inst : entity work.pid_velocity_axi_comm
    generic map(
		P_SIZE     => P_SIZE,
		I_SIZE     => I_SIZE,
		D_SIZE     => D_SIZE,
		SETPOINT_SIZE => DATA_IN_SIZE,
        BUS_SIZE   => C_S00_AXI_DATA_WIDTH -- Data port size for wishbone
    )
    port map(
		-- Syscon signals
		reset       => s00_axi_reset,
		clk         => s00_axi_aclk,
		-- Wishbone signals
		addr_i      => addr_s,       
		wr_en_i     => write_en_s,     
		writedata_i => s00_axi_wdata, 
		rd_en_i     => read_en_s,     
		readdata_o  => s00_axi_rdata,  
		kp_o        => kp_s,
		ki_o        => ki_s,
		kd_o        => kd_s,
		sign_o      => sign_s,
		setpoint_o  => setpoint_s,
		int_rst_o   => int_rst_s,
		is_input_o  => is_input_s
    );

	-- Instantiation of Axi Bus Interface S00_AXI
	handle_comm : entity work.pid_velocity_axi_handComm
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
		S_AXI_WSTRB	    => s00_axi_wstrb,
		S_AXI_WVALID	=> s00_axi_wvalid,
		S_AXI_WREADY	=> s00_axi_wready,
		S_AXI_BRESP	    => s00_axi_bresp,
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
