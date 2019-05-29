library ieee;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;

entity slv_to_sl_axi is
	generic (
		SLV_SIZE : natural := 16;
		DEFAULT_BIT_OFFSET: natural := 0;
		-- Parameters of Axi Slave Bus Interface S00_AXI
		C_S00_AXI_DATA_WIDTH	: integer	:= 32;
		C_S00_AXI_ADDR_WIDTH	: integer	:= 3
	);
	port (
		ref_clk_i : in std_logic;
		ref_rst_i : in std_logic;
		-- input data
		slv_i : in std_logic_vector(SLV_SIZE-1 downto 0);
		-- output data
		sl_o  : out std_logic;
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
end slv_to_sl_axi;

architecture arch_imp of slv_to_sl_axi is

	constant INTERNAL_ADDR_WIDTH : natural := 1;
	signal addr_s : std_logic_vector(INTERNAL_ADDR_WIDTH-1 downto 0);
	signal write_en_s, read_en_s : std_logic;

	constant OFFSET_ADDR_SZ : natural := natural(ceil(log2(real(SLV_SIZE))));
	signal offset_s, offset_sync_s : std_logic_vector(OFFSET_ADDR_SZ-1 downto 0);
	signal sl_s : std_logic;

begin

	sl_s <= slv_i(to_integer(unsigned(offset_sync_s)));

	process(ref_clk_i) begin
		if rising_edge(ref_clk_i) then
			if ref_rst_i = '1' then
				sl_o <= '0';
			else
				sl_o <= sl_s;
			end if;
		end if;
	end process;

	sync_offset_inst : entity work.slv_to_sl_axi_sync_slv
	generic map (DATA => OFFSET_ADDR_SZ)
	port map (clk_i => ref_clk_i, bit_i => offset_s,
		bit_o => offset_sync_s
	);

	-- Instantiation of Axi Bus Interface S00_AXI
	slv_to_sl_axi_comm_inst : entity work.slv_to_sl_axi_comm
	generic map (DEFAULT_BIT_OFFSET => DEFAULT_BIT_OFFSET,
		OFFSET_ADDR_SZ => OFFSET_ADDR_SZ,
		AXI_ADDR_WIDTH => INTERNAL_ADDR_WIDTH,
		C_S_AXI_DATA_WIDTH	=> C_S00_AXI_DATA_WIDTH
	)
	port map (clk_i => s00_axi_aclk, reset => s00_axi_reset,
		addr_i => addr_s,
		write_en_i	=> write_en_s, writedata => s00_axi_wdata,
		read_en_i	=> read_en_s, read_ack_o => s00_axi_rvalid,
		readdata	=> s00_axi_rdata,
		offset_o => offset_s
	);

	-- Instantiation of Axi Bus Interface S00_AXI
	handle_comm : entity work.slv_to_sl_axi_handCom
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
