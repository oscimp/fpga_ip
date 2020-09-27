module adc_dac_spi_control (
	// Data input
	input                       conf_sel_spi,
	input	                 	conf_en_spi,
	input	[ CONF_SIZE-1: 0]	conf_spi,

	// SPI output
	output                  dac_spi_clk_o,
	output                  dac_spi_csb_o,
	output                  dac_spi_sdio_o,
	output                  adc_spi_clk_o,
	output                  adc_spi_csb_o,
	output                  adc_spi_sdio_o,

	// Clock 
	input                   clk_i,
	input                   rst_i
);

    parameter CONF_SIZE = 21 ;


	reg	dac_spi_csb_o    ;
	reg	dac_spi_sdio_o   ;
	reg	dac_spi_clk_o    ;
	reg	adc_spi_csb_o    ;
	reg	adc_spi_sdio_o   ;
	reg	adc_spi_clk_o    ;
    
   
	always @(posedge clk_i) begin
		if (conf_sel_spi == 1'b1) begin
		    adc_spi_clk_o <= spi_clk_o;
		    adc_spi_csb_o <= spi_csb_o;
		    adc_spi_sdio_o <= spi_sdio_o;
			dac_spi_clk_o <= 1'b1;
			dac_spi_csb_o <= 1'b1;
			dac_spi_sdio_o <= 1'b0;
		end
		else begin
		    // The DACs keep their default configuration. However if an other configuration is desired, 
		    // CONF_SIZE will have to be fully included in the code (cf: ADC/DAC datasheet)
		    // CONF_SIZE is not yet taken in consderation in spi_master
		    dac_spi_clk_o <= spi_clk_o; 
		    dac_spi_csb_o <= spi_csb_o; 
		    dac_spi_sdio_o <= spi_sdio_o; 
			adc_spi_clk_o <= 1'b1;
            adc_spi_csb_o <= 1'b1;
            adc_spi_sdio_o <= 1'b0;
        end
	 end

	spi_master spi_master(
		// clk rst
		.clk			(clk_i), //i
		.reset			(rst_i), //i
		// start and 
		.start_en       (conf_en_spi), //i
		// data to send/receive
		.data_in        (conf_spi), //i
		// SPI interface signals
		.spi_clk		(spi_clk_o), //o
        .spi_mosi       (spi_sdio_o), //o
        .spi_cs_n       (spi_csb_o) //o
	);

endmodule