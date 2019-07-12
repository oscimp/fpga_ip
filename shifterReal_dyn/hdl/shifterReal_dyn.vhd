---------------------------------------------------------------------------
-- (c) Copyright: OscillatorIMP Digital
-- Author : Gwenhael Goavec-Merou<gwenhael.goavec-merou@trabucayre.com>
-- Creation date : 2016/05/25
---------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;
use IEEE.math_real.all;

entity shifterReal_dyn is
	generic (
		id                   : natural := 1;
		SIGNED_DATA          : boolean := true;
		DEFAULT_SHIFT        : natural := 0;
		DATA_IN_SIZE         : natural := 32;
		DATA_OUT_SIZE        : natural := 16;
		-- Parameters of Axi Slave Bus Interface S00_AXI
		C_S00_AXI_DATA_WIDTH : integer := 32;
		C_S00_AXI_ADDR_WIDTH : integer := 4
	);
	port (
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
		-- input
		data_i          : in std_logic_vector(DATA_IN_SIZE-1 downto 0);
		data_en_i       : in std_logic;
		data_eof_i      : in std_logic;
		data_sof_i      : in std_logic;
		data_rst_i      : in std_logic;
		data_clk_i      : in std_logic;
		-- output
		data_o          : out std_logic_vector(DATA_OUT_SIZE-1 downto 0);		
		data_en_o       : out std_logic;
		data_eof_o      : out std_logic;
		data_sof_o      : out std_logic;
		data_rst_o      : out std_logic;
		data_clk_o      : out std_logic
	);
end shifterReal_dyn;

architecture Behavioral of shifterReal_dyn is
                                         -- +1 => shift by 0
	constant MAX_SHIFT      : natural := DATA_IN_SIZE - DATA_OUT_SIZE + 1;
	constant SHFT_ADDR_SZ   : natural := natural(ceil(log2(real(MAX_SHIFT))));
	signal shift_val_s      : std_logic_vector(SHFT_ADDR_SZ-1 downto 0);
	signal shift_val_sync_s : std_logic_vector(SHFT_ADDR_SZ-1 downto 0);
	-- comm
	signal addr_s           : std_logic_vector(1 downto 0);
	signal wr_en_s, rd_en_s : std_logic;
begin
	data_clk_o <= data_clk_i;
	data_rst_o <= data_rst_i;
	
	shift_inst1 : entity work.shifterReal_dyn_logic
	generic map (SIGNED_FORMAT => SIGNED_DATA, MAX_SHIFT => MAX_SHIFT,
		ADDR_SZ => SHFT_ADDR_SZ,
		DATA_IN_SIZE => DATA_IN_SIZE, DATA_OUT_SIZE => DATA_OUT_SIZE)
	port map(clk_i => data_clk_i, rst_i => data_rst_i,
		shift_val_i => shift_val_sync_s,
		-- input
		data_i => data_i, data_en_i => data_en_i,
		data_eof_i => data_eof_i, data_sof_i => data_sof_i,
		--for next
		data_o => data_o, data_en_o => data_en_o,
		data_eof_o => data_eof_o, data_sof_o => data_sof_o);

	shift_sync: entity work.shifterReal_dyn_synchronizer_vector
	generic map (DATA => SHFT_ADDR_SZ)
	port map (ref_clk_i => s00_axi_aclk, clk_i => data_clk_i,
		bit_i => shift_val_s, bit_o => shift_val_sync_s
	);

	shift_comm_inst : entity work.shifterReal_dyn_comm
    generic map(id => id, wb_size => C_S00_AXI_DATA_WIDTH,
	SHFT_ADDR_SZ => SHFT_ADDR_SZ, DEFAULT_SHIFT => DEFAULT_SHIFT)
    port map(reset => s00_axi_reset, clk => s00_axi_aclk,
		-- Wishbone signals
		addr_i        => addr_s,       
		wr_en_i       => wr_en_s,     
		writedata_i   => s00_axi_wdata, 
		rd_en_i       => rd_en_s,     
		readdata_o    => s00_axi_rdata,  
		shift_val_o   => shift_val_s 
    );

	-- Instantiation of Axi Bus Interface S00_AXI
	handle_comm : entity work.shifterReal_dyn_handcomm
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
		read_en_o       => rd_en_s,
		write_en_o      => wr_en_s,
		addr_o => addr_s
	);

end Behavioral;

