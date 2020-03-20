library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

Entity pwm_axi is 
generic(
	ID                   : natural := 0;
	COUNTER_SIZE         : natural := 32;
	C_S00_AXI_DATA_WIDTH : integer := 32;
	C_S00_AXI_ADDR_WIDTH : integer := 5
);
port (
	-- CANDR signals
	s00_axi_reset   : in std_logic;
	s00_axi_aclk	: in std_logic;
	-- AXI signals
	s00_axi_awaddr	: in std_logic_vector(C_S00_AXI_ADDR_WIDTH-1 downto 0);
	s00_axi_awprot  : in std_logic_vector(2 downto 0);
	s00_axi_awvalid : in std_logic;
	s00_axi_awready : out std_logic;
	s00_axi_wdata   : in std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
	s00_axi_wstrb   : in std_logic_vector((C_S00_AXI_DATA_WIDTH/8)-1 downto 0);
	s00_axi_wvalid  : in std_logic;
	s00_axi_wready	: out std_logic;
	s00_axi_bresp   : out std_logic_vector(1 downto 0);
	s00_axi_bvalid  : out std_logic;
	s00_axi_bready  : in std_logic;
	s00_axi_araddr	: in std_logic_vector(C_S00_AXI_ADDR_WIDTH-1 downto 0);
	s00_axi_arprot	: in std_logic_vector(2 downto 0);
	s00_axi_arvalid : in std_logic;
	s00_axi_arready : out std_logic;
	s00_axi_rdata	: out std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
	s00_axi_rresp	: out std_logic_vector(1 downto 0);
	s00_axi_rvalid	: out std_logic;
	s00_axi_rready	: in std_logic;
	-- logic CANDR
	ref_rst_i: in std_logic;
	ref_clk_i: in std_logic;
	-- out signals
	pwm_o : out std_logic 
);
end entity pwm_axi;

Architecture bhv of pwm_axi is
	constant INTERNAL_ADDR_WIDTH : natural := 3;
	-- axi
	signal addr_s                : std_logic_vector(INTERNAL_ADDR_WIDTH-1 downto 0);
	signal write_en_s, read_en_s : std_logic;

	-- conf
	signal duty_s, duty_sync_s           : std_logic_vector(COUNTER_SIZE-1 downto 0);
	signal period_s, period_sync_s       : std_logic_vector(COUNTER_SIZE-1 downto 0);
	signal prescaler_s, prescaler_sync_s : std_logic_vector(COUNTER_SIZE-1 downto 0);
	signal enable_s, enable_sync_s       : std_logic;
	signal invert_s, invert_sync_s       : std_logic;
begin
	pwm_log_inst : entity work.pwm_logic
	generic map (COUNTER_SIZE => COUNTER_SIZE)
	port map(reset => ref_rst_i, clk => ref_clk_i,
		-- in signals
		enable_i => enable_sync_s, invert_i => invert_sync_s,
		duty_i => duty_sync_s, period_i => period_sync_s,
		prescaler_i => prescaler_sync_s, 
		-- out signals
		pwm_o => pwm_o
	);

	sync_duty: entity work.pwm_sync_vector
	generic map (DATA => COUNTER_SIZE)
	port map (ref_clk_i => s00_axi_aclk, clk_i => ref_clk_i,
		bit_i => duty_s, bit_o => duty_sync_s
	);
	sync_period: entity work.pwm_sync_vector
	generic map (DATA => COUNTER_SIZE)
	port map (ref_clk_i => s00_axi_aclk, clk_i => ref_clk_i,
		bit_i => period_s, bit_o => period_sync_s
	);
	sync_prescaler: entity work.pwm_sync_vector
	generic map (DATA => COUNTER_SIZE)
	port map (ref_clk_i => s00_axi_aclk, clk_i => ref_clk_i,
		bit_i => prescaler_s, bit_o => prescaler_sync_s
	);
	sync_enable: entity work.pwm_sync_bit
	port map (ref_clk_i => s00_axi_aclk, clk_i => ref_clk_i,
		bit_i => enable_s, bit_o => enable_sync_s
	);
	sync_invert: entity work.pwm_sync_bit
	port map (ref_clk_i => s00_axi_aclk, clk_i => ref_clk_i,
		bit_i => invert_s, bit_o => invert_sync_s
	);

	pwm_comm_inst : entity work.pwm_comm
	generic map(id => id, COUNTER_SIZE => COUNTER_SIZE,
		AXI_DATA_WIDTH => C_S00_AXI_DATA_WIDTH)
	port map(reset => s00_axi_reset, clk => s00_axi_aclk,
		-- axi signals
		addr_i		=> addr_s,
		write_en_i  => write_en_s,
		writedata   => s00_axi_wdata,
		read_en_i	=> read_en_s,
		read_ack_o	=> s00_axi_rvalid,
		readdata	=> s00_axi_rdata,
		-- out signals
		enable_o 	=> enable_s,
		invert_o 	=> invert_s,
		duty_o		=> duty_s,
		period_o	=> period_s,
		prescaler_o	=> prescaler_s
	);

	-- Instantiation of Axi Bus Interface S00_AXI
	handle_comm : entity work.pwm_handCom
	generic map (
		C_S_AXI_DATA_WIDTH  => C_S00_AXI_DATA_WIDTH,
		C_S_AXI_ADDR_WIDTH  => C_S00_AXI_ADDR_WIDTH,
		INTERNAL_ADDR_WIDTH => INTERNAL_ADDR_WIDTH
	)
	port map (
		S_AXI_ACLK		=> s00_axi_aclk,
		S_AXI_RESET		=> s00_axi_reset,
		S_AXI_AWADDR	=> s00_axi_awaddr,
		S_AXI_AWPROT	=> s00_axi_awprot,
		S_AXI_AWVALID   => s00_axi_awvalid,
		S_AXI_AWREADY   => s00_axi_awready,
		S_AXI_WSTRB		=> s00_axi_wstrb,
		S_AXI_WVALID	=> s00_axi_wvalid,
		S_AXI_WREADY	=> s00_axi_wready,
		S_AXI_BRESP		=> s00_axi_bresp,
		S_AXI_BVALID	=> s00_axi_bvalid,
		S_AXI_BREADY	=> s00_axi_bready,
		S_AXI_ARADDR	=> s00_axi_araddr,
		S_AXI_ARPROT	=> s00_axi_arprot,
		S_AXI_ARVALID   => s00_axi_arvalid,
		S_AXI_ARREADY   => s00_axi_arready,
		S_AXI_RRESP		=> s00_axi_rresp,
		S_AXI_RVALID	=> open,--s00_axi_rvalid,
		S_AXI_RREADY	=> s00_axi_rready,
		read_en_o		=> read_en_s,
		write_en_o		=> write_en_s,
		addr_o			=> addr_s
	);


end architecture bhv;

