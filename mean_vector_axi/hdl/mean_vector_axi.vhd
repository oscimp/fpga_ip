---------------------------------------------------------------------------
-- (c) Copyright: OscillatorIMP Digital
-- Author : Gwenhael Goavec-Merou<gwenhael.goavec-merou@trabucayre.com>
-- 2013-2019
---------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;
use IEEE.math_real.all;

entity mean_vector_axi is
	generic (
		id : natural := 1;
		MAX_NB_ACCUM 			: natural := 1024;
		DATA_SIZE 				: natural := 14;
		ADDR_SIZE 				: natural := 10;
		-- Parameters of Axi Slave Bus Interface S00_AXI
		C_S00_AXI_DATA_WIDTH	: integer	:= 32;
		C_S00_AXI_ADDR_WIDTH	: integer	:= 4
	);
	port (
		-- Wishbone signals
		s00_axi_aclk	: in std_logic;
		s00_axi_reset	: in std_logic;
		s00_axi_awaddr	: in std_logic_vector(C_S00_AXI_ADDR_WIDTH-1 downto 0);
		--s00_axi_awprot	: in std_logic_vector(2 downto 0);
		s00_axi_awvalid	: in std_logic;
		s00_axi_awready	: out std_logic;
		s00_axi_wdata	: in std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
		--s00_axi_wstrb	: in std_logic_vector((C_S00_AXI_DATA_WIDTH/8)-1 downto 0);
		s00_axi_wvalid	: in std_logic;
		s00_axi_wready	: out std_logic;
		s00_axi_bresp	: out std_logic_vector(1 downto 0);
		s00_axi_bvalid	: out std_logic;
		s00_axi_bready	: in std_logic;
		s00_axi_araddr	: in std_logic_vector(C_S00_AXI_ADDR_WIDTH-1 downto 0);
		--s00_axi_arprot	: in std_logic_vector(2 downto 0);
		s00_axi_arvalid	: in std_logic;
		s00_axi_arready	: out std_logic;
		s00_axi_rdata	: out std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
		s00_axi_rresp	: out std_logic_vector(1 downto 0);
		s00_axi_rvalid	: out std_logic;
		s00_axi_rready	: in std_logic;
		-- input
		data_i_i : in std_logic_vector(DATA_SIZE-1 downto 0);
		data_q_i : in std_logic_vector(DATA_SIZE-1 downto 0);
		data_en_i: in std_logic;
		data_eof_i: in std_logic;
		data_rst_i: in std_logic;
		data_clk_i: in std_logic;
		-- output
		data_q_o  : out std_logic_vector(DATA_SIZE-1 downto 0);
		data_i_o  : out std_logic_vector(DATA_SIZE-1 downto 0);		
		data_en_o : out std_logic;
		data_eof_o : out std_logic;
		data_rst_o : out std_logic;
		data_clk_o : out std_logic
	);
end mean_vector_axi;

architecture Behavioral of mean_vector_axi is
	-- 2^ACCUM_SIZE => NB_ACCUM (in fact 0 -> NB_ACCUM-1 but ...)
	constant ACCUM_SIZE : natural := natural(ceil(log2(real(MAX_NB_ACCUM))));
	-- we need to describe the shift size
	-- divide by 1024 is >> 10 => 10 must be used with 2^4 = 16
	constant SHIFT_SIZE : natural := natural(ceil(log2(real(ACCUM_SIZE))));

	signal nb_iter_s : std_logic_vector(ACCUM_SIZE-1 downto 0);
	signal nb_iter_sync_s : std_logic_vector(ACCUM_SIZE-1 downto 0);
	signal shift_val_s : std_logic_vector(SHIFT_SIZE-1 downto 0);
	signal shift_val_sync_s : std_logic_vector(SHIFT_SIZE-1 downto 0);
	-- comm
	signal addr_s : std_logic_vector(1 downto 0);
	signal write_en_s, read_en_s : std_logic;
begin
	data_clk_o <= data_clk_i;
	data_rst_o <= data_rst_i;
	
	logic_inst1 : entity work.mean_vector_axi_logic
	generic map (ADDR_SIZE => ADDR_SIZE,
		ACCUM_SIZE => ACCUM_SIZE, SHIFT_SIZE => SHIFT_SIZE,
		DATA_SIZE => DATA_SIZE)
	port map(clk_i => data_clk_i, rst_i => data_rst_i,
		--configuration (wishbone)
		shift_val_i => shift_val_s, nb_iter_i => nb_iter_sync_s,
		-- input
		data_i_i => data_i_i, data_q_i => data_q_i,
		data_en_i => data_en_i, data_eof_i => data_eof_i,
		--for next
		data_i_o => data_i_o, data_q_o => data_q_o,
		data_en_o => data_en_o, data_eof_o => data_eof_o);

	-- synchro --
	nb_iter_syn: entity work.mva_synchronizer_vector
	generic map (DATA => ACCUM_SIZE)
	port map (clk_i => data_clk_i,
		bit_i => nb_iter_s, bit_o => nb_iter_sync_s);
	shift_syn: entity work.mva_synchronizer_vector
	generic map (DATA => SHIFT_SIZE)
	port map (clk_i => data_clk_i,
		bit_i => shift_val_s, bit_o => shift_val_sync_s);
		
	-------------

	wb_shift_inst : entity work.wb_mean_vector_axi
    generic map(id => id, wb_size => C_S00_AXI_DATA_WIDTH,
		MAX_NB_ACCUM => MAX_NB_ACCUM,
		ACCUM_SIZE => ACCUM_SIZE, SHIFT_SIZE => SHIFT_SIZE)
    port map(reset => s00_axi_reset, clk => s00_axi_aclk,
		-- Wishbone signals
		wbs_add       => addr_s,       
		wbs_write     => write_en_s,     
		wbs_writedata => s00_axi_wdata, 
		wbs_read     => read_en_s,     
		wbs_readdata  => s00_axi_rdata,  
		shift_val_o => shift_val_s, 
		nb_iter_o => nb_iter_s 
    );

	-- Instantiation of Axi Bus Interface S00_AXI
	handle_comm : entity work.mean_vector_axi_handcomm
	generic map (
		C_S_AXI_DATA_WIDTH	=> C_S00_AXI_DATA_WIDTH,
		C_S_AXI_ADDR_WIDTH	=> C_S00_AXI_ADDR_WIDTH
	)
	port map (
		S_AXI_ACLK		=> s00_axi_aclk,
		S_AXI_RESET		=> s00_axi_reset,
		S_AXI_AWADDR	=> s00_axi_awaddr,
		--S_AXI_AWPROT	=> s00_axi_awprot,
		S_AXI_AWVALID	=> s00_axi_awvalid,
		S_AXI_AWREADY	=> s00_axi_awready,
		--S_AXI_WSTRB		=> s00_axi_wstrb,
		S_AXI_WVALID	=> s00_axi_wvalid,
		S_AXI_WREADY	=> s00_axi_wready,
		S_AXI_BRESP		=> s00_axi_bresp,
		S_AXI_BVALID	=> s00_axi_bvalid,
		S_AXI_BREADY	=> s00_axi_bready,
		S_AXI_ARADDR	=> s00_axi_araddr,
		--S_AXI_ARPROT	=> s00_axi_arprot,
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

