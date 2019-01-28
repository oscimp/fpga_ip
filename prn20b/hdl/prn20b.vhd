---------------------------------------------------------------------------
-- (c) Copyright: OscillatorIMP Digital
-- Author : Gwenhael Goavec-Merou<gwenhael.goavec-merou@trabucayre.com>
-- Creation date : 2018/06/11
---------------------------------------------------------------------------
library IEEE;

use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

entity prn20b is
	generic (
		DFLT_PRESC : natural := 15;
		PRESC_SIZE : natural := 16;
		-- Parameters of Axi Slave Bus Interface S00_AXI
		C_S00_AXI_DATA_WIDTH	: integer	:= 32;
		C_S00_AXI_ADDR_WIDTH	: integer	:= 3
	);
	port (
		-- Ports of Axi Lite Slave Bus Interface S00_AXI
		s00_axi_aclk	: in std_logic;
		s00_axi_reset   : in std_logic;
		s00_axi_awaddr  : in std_logic_vector(C_S00_AXI_ADDR_WIDTH-1 downto 0);
		s00_axi_awprot	: in std_logic_vector(2 downto 0);
		s00_axi_awvalid : in std_logic;
		s00_axi_awready : out std_logic;
		s00_axi_wdata   : in std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
		s00_axi_wstrb	: in std_logic_vector((C_S00_AXI_DATA_WIDTH/8)-1 downto 0);
		s00_axi_wvalid  : in std_logic;
		s00_axi_wready  : out std_logic;
		s00_axi_bresp   : out std_logic_vector(1 downto 0);
		s00_axi_bvalid  : out std_logic;
		s00_axi_bready  : in std_logic;
		s00_axi_araddr  : in std_logic_vector(C_S00_AXI_ADDR_WIDTH-1 downto 0);
		s00_axi_arprot	: in std_logic_vector(2 downto 0);
		s00_axi_arvalid : in std_logic;
		s00_axi_arready : out std_logic;
		s00_axi_rdata   : out std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
		s00_axi_rresp   : out std_logic_vector(1 downto 0);
		s00_axi_rvalid  : out std_logic;
		s00_axi_rready  : in std_logic;

		-- specific signals
		ref_clk_i : in std_logic;
		ref_rst_i : in std_logic;
		prn_full_o : out std_logic_vector(19 downto 0);
		prn_full_en_o : out std_logic;
		prn_full_clk_o : out std_logic;
		prn_full_rst_o : out std_logic;
		test_o : out std_logic;
		bit_o : out std_logic
	);
end prn20b;

architecture bhv of prn20b is
	--axi
	constant INTERNAL_ADDR_WIDTH : natural := 1;
	signal addr_s : std_logic_vector(INTERNAL_ADDR_WIDTH-1 downto 0);
	signal write_en_s, read_en_s : std_logic;

	signal prescaler_s, presc_sync_s : std_logic_vector(PRESC_SIZE-1 downto 0);
	signal tick_s : std_logic;
	signal test_s : std_logic;
begin
	test_o <= test_s;

	prn_full_clk_o <= ref_clk_i;
	prn_full_rst_o <= ref_rst_i;
	prn_full_en_o <= tick_s;

	process(ref_clk_i)
	begin
		if rising_edge(ref_clk_i) then
			if tick_s = '1' then
				test_s <= not test_s;
			else
				test_s <= test_s;
			end if;
		end if;
	end process;

	logic_inst : entity work.prn20b_logic
	port map (
		clk => ref_clk_i,
		reset => '0',
		tick_i => tick_s,
		prn_o => prn_full_o,
		bit_o => bit_o
	);

	presc_inst : entity work.prn20b_presc
	generic map (CPT_SIZE => PRESC_SIZE)
	port map (clk_i => ref_clk_i,
		rst_i => ref_rst_i,
		prescaler_i => presc_sync_s,
		clk_gen_o => open,
		tick_o => tick_s
	);

	prescSync: entity work.prn20b_vectSync
	generic map (stages => 3, DATA => PRESC_SIZE)
	port map (clk_i => ref_clk_i,
		bit_i => prescaler_s, bit_o => presc_sync_s);

	wb_inst : entity work.wb_prn20b
	generic map(
		PRESC_SIZE => PRESC_SIZE,
		DFLT_PRESC => DFLT_PRESC,
		ADDR_SIZE => INTERNAL_ADDR_WIDTH,
		wb_size   => C_S00_AXI_DATA_WIDTH
	)
	port map (reset => s00_axi_reset, clk => s00_axi_aclk,
		-- Axi signals
		wbs_add			=> addr_s,
		wbs_writedata => s00_axi_wdata,
		wbs_readdata  => s00_axi_rdata,
		wbs_read	=> read_en_s,
		wbs_read_ack => s00_axi_rvalid,
		wbs_write	 => write_en_s,
		--data 
		prescaler_o => prescaler_s
	);

	-- Instantiation of Axi Bus Interface S00_AXI
	handle_comm : entity work.prn20b_handCom
	generic map (
		C_S_AXI_DATA_WIDTH	=> C_S00_AXI_DATA_WIDTH,
		C_S_AXI_ADDR_WIDTH	=> C_S00_AXI_ADDR_WIDTH,
		INTERNAL_ADDR_WIDTH => INTERNAL_ADDR_WIDTH
	)
	port map (
		S_AXI_ACLK		=> s00_axi_aclk,
		S_AXI_RESET		=> s00_axi_reset,
		S_AXI_AWADDR	=> s00_axi_awaddr,
		--S_AXI_AWPROT	=> s00_axi_awprot,
		S_AXI_AWVALID	=> s00_axi_awvalid,
		S_AXI_AWREADY	=> s00_axi_awready,
		--S_AXI_WSTRB	=> s00_axi_wstrb,
		S_AXI_WVALID	=> s00_axi_wvalid,
		S_AXI_WREADY	=> s00_axi_wready,
		S_AXI_BRESP	=> s00_axi_bresp,
		S_AXI_BVALID	=> s00_axi_bvalid,
		S_AXI_BREADY	=> s00_axi_bready,
		S_AXI_ARADDR	=> s00_axi_araddr,
		--S_AXI_ARPROT	=> s00_axi_arprot,
		S_AXI_ARVALID	=> s00_axi_arvalid,
		S_AXI_ARREADY	=> s00_axi_arready,
		S_AXI_RRESP	=> s00_axi_rresp,
		S_AXI_RVALID	=> open,--s00_axi_rvalid,
		S_AXI_RREADY	=> s00_axi_rready,
		read_en_o => read_en_s,
		write_en_o => write_en_s,
		addr_o => addr_s
	);

end architecture bhv;

