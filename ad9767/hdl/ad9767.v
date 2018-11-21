module ad9767 (
	// DAC clks
	input			dac_clk_i,
	input			dac_2clk_i,
	input			dac_2ph_i,
	input			dac_locked_i,

  // DAC IC
  output [ 14-1: 0]dac_dat_o, //!< DAC IC combined data
  output			dac_wrt_o, //!< DAC IC write enable
  output			dac_sel_o, //!< DAC IC channel select
  output			  dac_clk_o, //!< DAC IC clock
  output			  dac_rst_o, //!< DAC IC reset
  
  input		dac_dat_a_en_i,
  input 	dac_dat_a_rst_i,
  input	[ 14-1: 0]dac_dat_a_i, //!< DAC CHA data
  input		dac_dat_b_en_i,
  input 	dac_dat_b_rst_i,
  input	[ 14-1: 0]dac_dat_b_i //!< DAC CHB data

);

	reg dac_rst;
	//---------------------------------------------------------------------------------
	//
	//  Fast DAC - DDR interface

	reg  [14-1: 0] dac_dat_a  ;
	reg  [14-1: 0] dac_dat_b  ;
	reg  [14-1: 0] dac_dat_a_s  ;
	reg  [14-1: 0] dac_dat_b_s  ;
	
	always @(posedge dac_clk_i) begin
		dac_dat_a_s <= dac_dat_a_s;
		dac_dat_b_s <= dac_dat_b_s;
		if (dac_dat_a_en_i == 1'b1)
			dac_dat_a_s <= dac_dat_a_i;
		if (dac_dat_b_en_i == 1'b1)
			dac_dat_b_s <= dac_dat_b_i;
	end


	// output registers + signed to unsigned (also to negative slope)
	always @(posedge dac_clk_i) begin
		dac_dat_a <= {dac_dat_a_s[14-1], ~dac_dat_a_s[14-2:0]};
		dac_dat_b <= {dac_dat_b_s[14-1], ~dac_dat_b_s[14-2:0]};
		dac_rst	<= !dac_locked_i;
	end

	ODDR i_dac_clk ( .Q(dac_clk_o), .D1(1'b0), .D2(1'b1), .C(dac_2ph_i),  .CE(1'b1), .R(dac_rst), .S(1'b0) );
	ODDR i_dac_wrt ( .Q(dac_wrt_o), .D1(1'b0), .D2(1'b1), .C(dac_2clk_i), .CE(1'b1), .R(dac_rst), .S(1'b0) );
	ODDR i_dac_sel ( .Q(dac_sel_o), .D1(1'b1), .D2(1'b0), .C(dac_clk_i ), .CE(1'b1), .R(dac_rst), .S(1'b0) );
	ODDR i_dac_rst ( .Q(dac_rst_o), .D1(dac_rst), .D2(dac_rst), .C(dac_clk_i ), .CE(1'b1), .R(1'b0), .S(1'b0) );

	ODDR i_dac_0  ( .Q(dac_dat_o[ 0]), .D1(dac_dat_b[ 0]), .D2(dac_dat_a[ 0]), .C(dac_clk_i), .CE(1'b1), .R(dac_rst), .S(1'b0) );
	ODDR i_dac_1  ( .Q(dac_dat_o[ 1]), .D1(dac_dat_b[ 1]), .D2(dac_dat_a[ 1]), .C(dac_clk_i), .CE(1'b1), .R(dac_rst), .S(1'b0) );
	ODDR i_dac_2  ( .Q(dac_dat_o[ 2]), .D1(dac_dat_b[ 2]), .D2(dac_dat_a[ 2]), .C(dac_clk_i), .CE(1'b1), .R(dac_rst), .S(1'b0) );
	ODDR i_dac_3  ( .Q(dac_dat_o[ 3]), .D1(dac_dat_b[ 3]), .D2(dac_dat_a[ 3]), .C(dac_clk_i), .CE(1'b1), .R(dac_rst), .S(1'b0) );
	ODDR i_dac_4  ( .Q(dac_dat_o[ 4]), .D1(dac_dat_b[ 4]), .D2(dac_dat_a[ 4]), .C(dac_clk_i), .CE(1'b1), .R(dac_rst), .S(1'b0) );
	ODDR i_dac_5  ( .Q(dac_dat_o[ 5]), .D1(dac_dat_b[ 5]), .D2(dac_dat_a[ 5]), .C(dac_clk_i), .CE(1'b1), .R(dac_rst), .S(1'b0) );
	ODDR i_dac_6  ( .Q(dac_dat_o[ 6]), .D1(dac_dat_b[ 6]), .D2(dac_dat_a[ 6]), .C(dac_clk_i), .CE(1'b1), .R(dac_rst), .S(1'b0) );
	ODDR i_dac_7  ( .Q(dac_dat_o[ 7]), .D1(dac_dat_b[ 7]), .D2(dac_dat_a[ 7]), .C(dac_clk_i), .CE(1'b1), .R(dac_rst), .S(1'b0) );
	ODDR i_dac_8  ( .Q(dac_dat_o[ 8]), .D1(dac_dat_b[ 8]), .D2(dac_dat_a[ 8]), .C(dac_clk_i), .CE(1'b1), .R(dac_rst), .S(1'b0) );
	ODDR i_dac_9  ( .Q(dac_dat_o[ 9]), .D1(dac_dat_b[ 9]), .D2(dac_dat_a[ 9]), .C(dac_clk_i), .CE(1'b1), .R(dac_rst), .S(1'b0) );
	ODDR i_dac_10 ( .Q(dac_dat_o[10]), .D1(dac_dat_b[10]), .D2(dac_dat_a[10]), .C(dac_clk_i), .CE(1'b1), .R(dac_rst), .S(1'b0) );
	ODDR i_dac_11 ( .Q(dac_dat_o[11]), .D1(dac_dat_b[11]), .D2(dac_dat_a[11]), .C(dac_clk_i), .CE(1'b1), .R(dac_rst), .S(1'b0) );
	ODDR i_dac_12 ( .Q(dac_dat_o[12]), .D1(dac_dat_b[12]), .D2(dac_dat_a[12]), .C(dac_clk_i), .CE(1'b1), .R(dac_rst), .S(1'b0) );
	ODDR i_dac_13 ( .Q(dac_dat_o[13]), .D1(dac_dat_b[13]), .D2(dac_dat_a[13]), .C(dac_clk_i), .CE(1'b1), .R(dac_rst), .S(1'b0) );

endmodule

