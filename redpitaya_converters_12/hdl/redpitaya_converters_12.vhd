library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity redpitaya_converters_12 is
generic (
	ADC_EN : boolean := true;
	DAC_EN : boolean := true;
	C_S00_AXI_DATA_WIDTH : integer := 32;
	C_S00_AXI_ADDR_WIDTH : integer := 5
);
port (
	-- SPI DAC control
    dac_spi_clk_o         : out std_logic;
    dac_spi_csb_o         : out std_logic := '1';
    dac_spi_sdio_o        : out std_logic;

	-- SPI ADC control
    adc_spi_clk_o	  : out std_logic;
    adc_spi_csb_o	  : out std_logic := '1';
    adc_spi_sdio_o	  : out std_logic;

	-- CANDR
	adc_rst_i       : in std_logic;
    clk_o           : out std_logic;
    rst_o           : out std_logic;
    rstn_o          : out std_logic;

	-- input diff clk
	adc_clk_p_i     : in std_logic;
	adc_clk_n_i     : in std_logic;

	-- adc
    --   phys ADC
    adc_data_p_a_i    : in std_logic_vector(7-1 downto 0);
    adc_data_n_a_i    : in std_logic_vector(7-1 downto 0);
    adc_data_p_b_i    : in std_logic_vector(7-1 downto 0);
    adc_data_n_b_i    : in std_logic_vector(7-1 downto 0);
    --   adc data to design
    data_a_o        : out std_logic_vector(12-1 downto 0);
    data_a_en_o     : out std_logic;
    data_a_clk_o    : out std_logic;
    data_a_rst_o    : out std_logic;
    data_b_o        : out std_logic_vector(12-1 downto 0);
    data_b_en_o     : out std_logic;
    data_b_clk_o    : out std_logic;
    data_b_rst_o    : out std_logic;

	-- ad9746
	--  from design
	dac_dat_a_en_i  : in std_logic := '0';
	dac_dat_a_rst_i : in std_logic := '1';
	dac_dat_a_i     : in std_logic_vector(13 downto 0) := (others => '0');
	dac_dat_b_en_i  : in std_logic := '0';
	dac_dat_b_rst_i : in std_logic := '1';
	dac_dat_b_i     : in std_logic_vector(13 downto 0) := (others => '0');
	--  phys
	dac_rst_o         : out std_logic := '1';
	dac_dat_a_o       : out std_logic_vector(13 downto 0);
	dac_dat_b_o       : out std_logic_vector(13 downto 0);

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
        s00_axi_rready : in std_logic;
        
     -- PLL
     pll_ref_i	    : in std_logic;
	 pll_hi_o      : out std_logic;
	 pll_lo_o      : out std_logic
	 
);
end entity redpitaya_converters_12;

architecture rtl of redpitaya_converters_12 is
        
	component ad9746 is
	port (
		-- from design
		dac_dat_a_en_i  : in std_logic;
		dac_dat_a_rst_i : in std_logic;
		dac_dat_a_i     : in std_logic_vector(13 downto 0);
		dac_dat_b_en_i  : in std_logic;
		dac_dat_b_rst_i : in std_logic;
		dac_dat_b_i     : in std_logic_vector(13 downto 0);
		--  phys
		dac_dat_a_o       : out std_logic_vector(13 downto 0);
		dac_dat_b_o       : out std_logic_vector(13 downto 0);
		dac_rst_o         : out std_logic;
		-- clk
		dac_locked_i    : in std_logic;
		dac_clk_i       : in std_logic
	);
	end component ad9746;

    signal adc_clk_s    : std_logic;
	signal adc_rstn_s   : std_logic;
	signal adc_rst_s    : std_logic;
	signal data_en_s    : std_logic;

    component ad9613 is
    port (
            -- from design
            adc_data_en     : out std_logic;
            adc_data_a      : out std_logic_vector(11 downto 0);
            adc_data_b      : out std_logic_vector(11 downto 0);
            -- phys
            adc_data_p_a_i     : in std_logic_vector(6 downto 0);
            adc_data_n_a_i     : in std_logic_vector(6 downto 0);
            adc_data_p_b_i     : in std_logic_vector(6 downto 0);
            adc_data_n_b_i     : in std_logic_vector(6 downto 0);
            -- clk
            adc_clk2d_i     : in std_logic;
            adc_clk_i       : in std_logic;
		    resetn          : in std_logic
    );
    end component ad9613;


	signal dac_clk_s, adc_clk2d_s : std_logic;
	signal adc_10mhz_s, dac_locked_s : std_logic;

	component redpitaya_adc_dac_clk is
	port (
		adc_clk_p_i  : in std_logic;
		adc_clk_n_i  : in std_logic;
		adc_rst_i    : in std_logic;
		ser_clk_o    : out std_logic;
		-- dac
		dac_clk_o    : out std_logic;
		adc_clk2d_o  : out std_logic;
		adc_10mhz_o  : out std_logic;
		dac_locked_o : out std_logic;
		
		-- adc 
		adc_clk_o    : out std_logic;
		adc_rstn_o   : out std_logic;
		adc_rst_o    : out std_logic
	);
	end component redpitaya_adc_dac_clk;

        constant CONF_SIZE: integer := 21;
        signal addr_s : std_logic_vector(1 downto 0);
        signal write_en_s, read_en_s : std_logic;
        signal conf_s, conf_spi : std_logic_vector(CONF_SIZE-1 downto 0);
        signal conf_en_s, conf_en_spi : std_logic;
        signal conf_sel_s, conf_sel_spi : std_logic;

	    component adc_dac_spi_control is
		generic (CONF_SIZE : integer);
        port (
		      -- Data input
		      conf_spi	      : in std_logic_vector(CONF_SIZE-1 downto 0);
		      conf_sel_spi      : in std_logic;
		      conf_en_spi       : in std_logic;

		      -- SPI output
        		dac_spi_clk_o	  : out std_logic;
        		dac_spi_csb_o	  : out std_logic;
		      dac_spi_sdio_o	  : out std_logic;
		      adc_spi_clk_o	  : out std_logic;
		      adc_spi_csb_o	  : out std_logic;
		      adc_spi_sdio_o    : out std_logic;

		      -- Clock
		      clk_i		  : in std_logic;
		      rst_i         : in std_logic
        );
        end component adc_dac_spi_control;

        signal pll_cfg_en_s, pll_cfg_en_o : std_logic;

	    component Si571_pll is
        port (
              pll_cfg_en    : in std_logic;
		      pll_ref_i	    : in std_logic;
		      pll_hi_o      : out std_logic;
		      pll_lo_o      : out std_logic;
		      clk_i		    : in std_logic;
		      clk_10mhz     : in std_logic;
		      rstn_i        : in std_logic
        );
        end component Si571_pll;

	------------------------------------------------------------------------
	--signal toto         : std_logic; 
	--signal toto2         : std_logic;
	------------------------------------------------------------------------
begin

-----------------------------------------------------------------------------------------------------------------------------
-- CLOCK
-----------------------------------------------------------------------------------------------------------------------------

	clk_o          <= adc_clk_s;
	rst_o          <= adc_rst_s;
	------------------------------------------------------------------------
	rstn_o         <= adc_rstn_s;
    --rstn_o <= toto2; 
    ------------------------------------------------------------------------
            
	redpitaya_clk: redpitaya_adc_dac_clk
	port map (
		adc_clk_p_i  => adc_clk_p_i,
		adc_clk_n_i  => adc_clk_n_i,
		adc_rst_i    => adc_rst_i,
		ser_clk_o    => open,
		dac_clk_o    => dac_clk_s,
		adc_clk2d_o  => adc_clk2d_s,
		adc_10mhz_o  => adc_10mhz_s,
		dac_locked_o => dac_locked_s,
		adc_clk_o    => adc_clk_s,
		adc_rstn_o   => adc_rstn_s,
		adc_rst_o    => adc_rst_s
	);
	
-----------------------------------------------------------------------------------------------------------------------------
-- DAC 
-----------------------------------------------------------------------------------------------------------------------------

	disable_dac: if DAC_EN = false generate
		dac_dat_a_o <= (others => '1');
		dac_dat_b_o <= (others => '1');
	end generate disable_dac;

	enable_dac: if DAC_EN = true generate
	-------------------------------------------------------------------
		--dac_rst_o <= toto ; 
    -------------------------------------------------------------------
    
		redpitaya_dac: ad9746
		port map (
			dac_dat_a_en_i  => dac_dat_a_en_i,
			dac_dat_a_rst_i => dac_dat_a_rst_i,
			dac_dat_a_i     => dac_dat_a_i,
			dac_dat_b_en_i  => dac_dat_b_en_i,
			dac_dat_b_rst_i => dac_dat_b_rst_i,
			dac_dat_b_i     => dac_dat_b_i,
			dac_dat_b_o     => dac_dat_b_o,
			dac_dat_a_o     => dac_dat_a_o,
			------------------------------------------------------------
			dac_rst_o       => dac_rst_o,
			--dac_rst_o        => open,
			------------------------------------------------------------
			-- clk
			dac_locked_i    => dac_locked_s,
			dac_clk_i       => dac_clk_s
		);
	end generate enable_dac;

-----------------------------------------------------------------------------------------------------------------------------
-- ADC 
-----------------------------------------------------------------------------------------------------------------------------

	disable_adc: if ADC_EN = false generate
		data_a_o     <= (others => '0');
		data_a_en_o  <= '0';
		data_a_clk_o <= '0';
		data_a_rst_o <= '1';
		data_b_o     <= (others => '0');
		data_b_en_o  <= '0';
		data_b_clk_o <= '0';
		data_b_rst_o <= '1';

	end generate disable_adc;

	enable_adc: if ADC_EN = true generate
		data_a_en_o  <= data_en_s;
		data_a_clk_o <= adc_clk_s;
		data_a_rst_o <= adc_rst_s;

		data_b_en_o  <= data_en_s;
		data_b_clk_o <= adc_clk_s;
		data_b_rst_o <= adc_rst_s;
		
		redpitaya_adc: ad9613
		port map (
			-- a/d
			adc_clk_i    => dac_clk_s,
			adc_clk2d_i  => adc_clk2d_s,
			resetn       => adc_rstn_s,
			-- a/d a-b
			adc_data_p_a_i => adc_data_p_a_i,
			adc_data_n_a_i => adc_data_n_a_i,
			adc_data_p_b_i => adc_data_p_b_i,
			adc_data_n_b_i => adc_data_n_b_i,
			-- a/d dat
			adc_data_en  => data_en_s,
			adc_data_a   => data_a_o,
			adc_data_b   => data_b_o
		);
	end generate enable_adc;

-----------------------------------------------------------------------------------------------------------------------------
-- ADC DAC SPI CONTROL
-----------------------------------------------------------------------------------------------------------------------------
	
	spi_en_conf : entity work.redpitaya_converters_12_sync_bit
	port map (ref_clk_i=> s00_axi_aclk, clk_i => dac_clk_s,
                bit_i => conf_en_s, bit_o => conf_en_spi);
	spi_sel_conf : entity work.redpitaya_converters_12_sync_bit
	port map (ref_clk_i=> s00_axi_aclk, clk_i => dac_clk_s,
                bit_i => conf_sel_s, bit_o => conf_sel_spi);
	spi_conf : entity work.redpitaya_converters_12_sync_vector
        generic map (DATA => CONF_SIZE)
        port map (ref_clk_i=> s00_axi_aclk, clk_i => dac_clk_s, 
                bit_i => conf_s, bit_o => conf_spi);
    pll_cfg_en : entity work.redpitaya_converters_12_sync_bit
	port map (ref_clk_i=> s00_axi_aclk, clk_i => dac_clk_s,
                bit_i => pll_cfg_en_s, bit_o => pll_cfg_en_o);            
                
    comm_inst : entity work.redpitaya_converters_12_comm
        generic map(
                    CONF_SIZE     => CONF_SIZE,
            BUS_SIZE   => C_S00_AXI_DATA_WIDTH -- Data port size for wishbone
        )
        port map(
                    -- Syscon signals
                    reset        => s00_axi_reset,
                    clk          => s00_axi_aclk,
                    -- Wishbone signals
                    addr_i       => addr_s,
                    write_en_i   => write_en_s,
                    writedata    => s00_axi_wdata,
                    read_en_i    => read_en_s,
                    readdata     => s00_axi_rdata,
                    conf_o       => conf_s,
                    conf_en_o    => conf_en_s,
                    conf_sel_o   => conf_sel_s,
                    pll_cfg_en_o => pll_cfg_en_s

        );
        

	spi_control: adc_dac_spi_control
	    generic map (CONF_SIZE => CONF_SIZE)
        port map (
		-- Data input
		conf_en_spi	  => conf_en_spi,
		conf_sel_spi  => conf_sel_spi,
		conf_spi	  => conf_spi,

		-- SPI output
		dac_spi_clk_o	=> dac_spi_clk_o,
		dac_spi_csb_o	=> dac_spi_csb_o,
		dac_spi_sdio_o	=> dac_spi_sdio_o,
		adc_spi_sdio_o	=> adc_spi_sdio_o,
		adc_spi_clk_o	=> adc_spi_clk_o,
		adc_spi_csb_o	=> adc_spi_csb_o,

		-- Clock
		clk_i		=> adc_clk_s,
		rst_i       => adc_rst_s
        );	

	
    -- Instantiation of Axi Bus Interface S00_AXI
    handle_comm : entity work.redpitaya_converters_12_handComm
    generic map (C_S_AXI_DATA_WIDTH => C_S00_AXI_DATA_WIDTH,
            C_S_AXI_ADDR_WIDTH      => C_S00_AXI_ADDR_WIDTH)
    port map (
            S_AXI_ACLK              => s00_axi_aclk,
            S_AXI_RESET             => s00_axi_reset,
            S_AXI_AWADDR    => s00_axi_awaddr,
            S_AXI_AWPROT    => s00_axi_awprot,
            S_AXI_AWVALID   => s00_axi_awvalid,
            S_AXI_AWREADY   => s00_axi_awready,
            S_AXI_WSTRB         => s00_axi_wstrb,
            S_AXI_WVALID    => s00_axi_wvalid,
            S_AXI_WREADY    => s00_axi_wready,
            S_AXI_BRESP         => s00_axi_bresp,
            S_AXI_BVALID    => s00_axi_bvalid,
            S_AXI_BREADY    => s00_axi_bready,
            S_AXI_ARADDR    => s00_axi_araddr,
            S_AXI_ARPROT    => s00_axi_arprot,
            S_AXI_ARVALID   => s00_axi_arvalid,
            S_AXI_ARREADY   => s00_axi_arready,
            S_AXI_RRESP     => s00_axi_rresp,
            S_AXI_RVALID    => s00_axi_rvalid,
            S_AXI_RREADY    => s00_axi_rready,
	        read_en_o => read_en_s,
            write_en_o => write_en_s,
            addr_o => addr_s);
            
-----------------------------------------------------------------------------------------------------------------------------
-- PLL ENABLE 
-----------------------------------------------------------------------------------------------------------------------------            

           
        pll_to_vcxo: Si571_pll
        port map (
              pll_cfg_en => pll_cfg_en_o,
              ------------------------------------------------------------
		      pll_hi_o   => pll_hi_o,
		      --pll_hi_o   => toto,
		      pll_lo_o   => pll_lo_o,
		      --pll_lo_o   => toto2,
		      ------------------------------------------------------------
		      pll_ref_i  => pll_ref_i,
		      -- Clock
		      clk_i		 => adc_clk_s,
		      clk_10mhz  => adc_10mhz_s,
		      rstn_i     => adc_rst_s
        ); 
            
end rtl;
