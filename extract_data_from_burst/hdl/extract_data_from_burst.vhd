library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

entity extract_data_from_burst is
	generic (
		ID : natural := 1;
		DATA_SIZE : natural := 16;
		POINT_POS : natural := 70;
		C_S00_AXI_DATA_WIDTH	: integer	:= 32;
		C_S00_AXI_ADDR_WIDTH	: integer	:= 4
	);
	port (
		--processing
		data_i_i	: in std_logic_vector(DATA_SIZE-1 downto 0);
		data_q_i	: in std_logic_vector(DATA_SIZE-1 downto 0);
		data_eof_i	: in std_logic;
		data_en_i	: in std_logic;
		data_clk_i	: in std_logic;
		data_rst_i	: in std_logic;
		data_i_o	: out std_logic_vector(DATA_SIZE-1 downto 0);
		data_q_o	: out std_logic_vector(DATA_SIZE-1 downto 0);
		data_en_o	: out std_logic;
		data_clk_o	: out std_logic;
		data_rst_o	: out std_logic;
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
end extract_data_from_burst;

architecture Behavioral of extract_data_from_burst is
	type state_type is (state_idle, state_count);
	signal state_reg : state_type;
	signal data_i_s, data_q_s : std_logic_vector(DATA_SIZE-1 downto 0);
	signal data_en_s : std_logic;
	signal cpt_s : natural range 0 to 2**16-1;

	-- comm
	signal addr_s : std_logic_vector(1 downto 0);
	signal write_en_s, read_en_s : std_logic;
	signal point_pos_s : std_logic_vector(15 downto 0);
	signal pos_ret1_s, pos_ret2_s: std_logic_vector(15 downto 0);
	signal point_pos_en_s : std_logic;
	signal point_pos_en2_s : std_logic;
	signal point_pos_nat_s : natural range 0 to 2**16-1;
begin
	data_i_o <= data_i_s;	
	data_q_o <= data_q_s;	
	data_en_o <= data_en_s;
	data_clk_o <= data_clk_i;
	data_rst_o <= data_rst_i;

	point_pos_nat_s <= to_integer(unsigned(pos_ret2_s));

	process(data_clk_i)
	begin
		if rising_edge(data_clk_i) then
			if data_rst_i = '1' then
				pos_ret2_s <= (others => '0');
			else
				pos_ret2_s <= pos_ret2_s;
				if point_pos_en2_s = '1' then
					pos_ret2_s <= pos_ret1_s;
				end if;
			end if;
		end if;
	end process;

	process(data_clk_i)
	begin
		if rising_edge(data_clk_i) then
			if data_rst_i = '1' then
				pos_ret1_s <= (others => '0');
				point_pos_en2_s <= '0';
			else
				pos_ret1_s <= pos_ret1_s;
				point_pos_en2_s <= '0';
				if point_pos_en_s = '1' then
					pos_ret1_s <= point_pos_s;
					point_pos_en2_s <= '1';
				end if;
			end if;
		end if;
	end process;

	process(data_clk_i)
	begin
		if rising_edge(data_clk_i) then
			if data_rst_i = '1' then
				state_reg <= state_idle;
				data_en_s <= '0';
				data_i_s <= (others => '0');
				data_q_s <= (others => '0');
				cpt_s <= 0;
			else
				data_en_s <= '0';
				data_i_s <= data_i_s;
				data_q_s <= data_q_s;
				state_reg <= state_reg;
				cpt_s <= cpt_s;
				case state_reg is
				when state_idle =>
					if data_eof_i = '1' then
						state_reg <= state_count;
						cpt_s <= 0;
					end if;
				when state_count =>
					if data_en_i = '1' then
						if cpt_s < point_pos_nat_s - 1 then
							cpt_s <= cpt_s +1;
						else
							data_en_s <= '1';
							data_i_s <= data_i_i;
							data_q_s <= data_q_i;
							state_reg <= state_idle;
						end if;
					end if;
				end case;
			end if;
		end if;
	end process;

	wb_edfb_inst : entity work.wb_edfb
    generic map(
        id        => id,
		POINT_POS => POINT_POS,
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
		point_pos_en_o => point_pos_en_s,
		point_pos_o => point_pos_s
    );

	-- Instantiation of Axi Bus Interface S00_AXI
	handle_comm : entity work.edfb_handComm
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

