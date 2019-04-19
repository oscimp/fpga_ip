library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

entity axi_to_dac is
	generic (
		DATA_SIZE : natural := 14;
		id : natural := 1;
		-- Parameters of Axi Slave Bus Interface S00_AXI
		C_S00_AXI_DATA_WIDTH	: integer	:= 32;
		C_S00_AXI_ADDR_WIDTH	: integer	:= 4
	);
	port (
		-- Syscon signals
		processing_clk_i : in std_logic;
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
		-- output
		data_a_o	: out std_logic_vector(DATA_SIZE-1 downto 0);
		data_a_en_o : out std_logic;
		data_b_o	: out std_logic_vector(DATA_SIZE-1 downto 0);
		data_b_en_o	: out std_logic
	);
end axi_to_dac;

architecture Behavioral of axi_to_dac is
	signal data1_a_s : std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
	signal data1_b_s : std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
	signal data2_a_s : std_logic_vector(DATA_SIZE-1 downto 0);
	signal data2_b_s : std_logic_vector(DATA_SIZE-1 downto 0);
	signal data1_a_en_s: std_logic;
	signal data1_b_en_s: std_logic;
	-- comm
	signal addr_s : std_logic_vector(1 downto 0);
	signal write_en_s, read_en_s : std_logic;
begin
    data_a_o <= data2_a_s;
    data_b_o <= data2_b_s;

	process(processing_clk_i, s00_axi_reset)
	begin
		if s00_axi_reset = '1' then
			data2_a_s <= (others => '0');
			data_a_en_o <= '0';
			data2_b_s <= (others => '0');
			data_b_en_o <= '0';
		elsif rising_edge(processing_clk_i) then
			data2_a_s <= data2_a_s;
			data_a_en_o <= '0';
			data2_b_s <= data2_b_s;
			data_b_en_o <= '0';
			if data1_a_en_s = '1' then
				data2_a_s <= data1_a_s(DATA_SIZE-1 downto 0);
				data_a_en_o <= '1';
			end if;
			if data1_b_en_s = '1' then
				data2_b_s <= data1_b_s(DATA_SIZE-1 downto 0);
				data_b_en_o <= '1';
			end if;
		end if;
	end process;

	wb_atd_inst : entity work.wb_axi_to_dac
    generic map(
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
		data_a_o => data1_a_s,
		data_a_en_o => data1_a_en_s,
		data_b_o => data1_b_s,
		data_b_en_o => data1_b_en_s
    );

	-- Instantiation of Axi Bus Interface S00_AXI
	handle_comm : entity work.axi_to_dac_handcomm
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

