module ad9746 (
	// DAC clks
	input			dac_clk_i,
	input			dac_locked_i,

	// DAC
	output  [ 14-1: 0]      dac_dat_a_o, //!< DAC combined data
	output  [ 14-1: 0]      dac_dat_b_o, //!< DAC combined data
	output                  dac_rst_o,

	input				dac_dat_a_en_i,
	input				dac_dat_a_rst_i,
	input	[ 14-1: 0]	dac_dat_a_i, //!< DAC CHA data
	input				dac_dat_b_en_i,
	input 				dac_dat_b_rst_i,
	input	[ 14-1: 0]	dac_dat_b_i //!< DAC CHB data

);

	//---------------------------------------------------------------------------------
	//
	//  Fast DAC - DDR interface

	reg  [14-1: 0] dac_dat_a_o    ;
	reg  [14-1: 0] dac_dat_b_o    ;
	reg  [14-1: 0] dac_dat_a_s    ;
	reg  [14-1: 0] dac_dat_b_s    ;
	reg            dac_rst_o      ;

	always @(posedge dac_clk_i) begin
		dac_dat_a_s <= dac_dat_a_s;
		dac_dat_b_s <= dac_dat_b_s;
		if (dac_dat_a_en_i == 1'b1)
			dac_dat_a_s <= dac_dat_a_i;
		if (dac_dat_b_en_i == 1'b1)
			dac_dat_b_s <= dac_dat_b_i;
	end

	always @(posedge dac_clk_i) begin
		dac_dat_a_o <= dac_dat_b_s;
		dac_dat_b_o <= dac_dat_a_s;
		dac_rst_o <= !dac_locked_i;
	end

endmodule

