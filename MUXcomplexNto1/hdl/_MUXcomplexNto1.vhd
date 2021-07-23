library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
use IEEE.MATH_REAL.all;

library xil_defaultlib;
use xil_defaultlib.mylib.all; 


entity MUXcomplexNto1 is
	generic 
	(   
	    ID : NATURAL := 1;
		INPUTS : positive := 4;
		DEFAULT_INPUT : natural := 0;
		DATA_SIZE : natural := 16;
		C_S00_AXI_DATA_WIDTH	: integer	:= 32;
		C_S00_AXI_ADDR_WIDTH	: integer	:= 4
	);
	port (
		--processing
		data_i_i	: in STD_LOGIC_VECTOR_ARRAY_T(0 to INPUTS - 1)(DATA_SIZE - 1 downto 0):= (others =>(others => '0'));	
		data_q_i	: in STD_LOGIC_VECTOR_ARRAY_T(0 to INPUTS - 1)(DATA_SIZE - 1 downto 0):= (others =>(others => '0'));
		data_en_i	: in STD_LOGIC_ARRAY_T(INPUTS - 1 downto 0):= (others =>'0');
        data_clk_i	: in STD_LOGIC_ARRAY_T(INPUTS - 1 downto 0):= (others =>'0');
        data_eof_i	: in STD_LOGIC_ARRAY_T(INPUTS - 1 downto 0):= (others =>'0');
		data_rst_i	: in STD_LOGIC_ARRAY_T(INPUTS - 1 downto 0):= (others =>'0');
      
      --  select_i    : in STD_LOGIC_VECTOR(integer(log2(real(INPUTS))) - 1 downto 0);
        
		data_i_o	: out STD_LOGIC_VECTOR(DATA_SIZE-1 downto 0);
		data_q_o	: out STD_LOGIC_VECTOR(DATA_SIZE-1 downto 0);
		data_en_o	: out STD_LOGIC;
        data_clk_o	: out STD_LOGIC;
        data_eof_o	: out STD_LOGIC;
		data_rst_o	: out STD_LOGIC;
		
		
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
        s00_axi_rready	: in std_logic
    );   
 
end MUXcomplexNto1;

architecture Behavioral of MUXcomplexNto1 is
    constant SEL_SIZE : integer := integer(ceil(log2(real(INPUTS))));
    signal addr_s : std_logic_vector(1 downto 0);
	signal write_en_s, read_en_s : std_logic;
	--signal witchIn : std_logic;
	signal select_s : std_logic_vector(SEL_SIZE - 1 downto 0);
	signal witchIn_sync: std_logic;

begin
    data_i_o   <= data_i_i(to_integer(unsigned(select_s)));
    data_q_o   <= data_q_i(to_integer(unsigned(select_s)));
    data_en_o  <= data_en_i(to_integer(unsigned(select_s)));
    data_clk_o <= data_clk_i(to_integer(unsigned(select_s)));
    data_eof_o <= data_eof_i(to_integer(unsigned(select_s)));
    data_rst_o <= data_rst_i(to_integer(unsigned(select_s))); 
    
    
    
    
    switchComplexWb_inst : entity work.MUXcomplexNto1_wb
    generic map(
        id        => id,
		DEFAULT_INPUT => DEFAULT_INPUT,
        wb_size   => C_S00_AXI_DATA_WIDTH, -- Data port size for wishbone
        SEL_SIZE => SEL_SIZE
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
		outputselect => select_s
    );
    	-- Instantiation of Axi Bus Interface S00_AXI
	handle_comm : entity work.MUXcomplex_handComm
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
		S_AXI_RVALID	=> s00_axi_rvalid,
		S_AXI_RREADY	=> s00_axi_rready,
		read_en_o => read_en_s,
		write_en_o => write_en_s,
		addr_o => addr_s
	);

end Behavioral;