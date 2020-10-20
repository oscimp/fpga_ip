module ad9613 
(
	// ADC clks
	input			adc_clk_i    ,
	input			adc_clk2d_i  ,
	input			resetn       ,

	// ADC
	input   [ 7-1: 0]  adc_data_p_a_i  ,  // ADC data cha p
	input   [ 7-1: 0]  adc_data_p_b_i  ,  // ADC data chb p
	input   [ 7-1: 0]  adc_data_n_a_i  ,  // ADC data cha n
	input   [ 7-1: 0]  adc_data_n_b_i  ,  // ADC data chb n

	output			adc_data_en ,
	output  [ 12-1: 0]      adc_data_a  ,
	output  [ 12-1: 0]      adc_data_b
);

	wire  [ 7-1: 0]   adc_dat_a_ibuf  ;
	wire  [ 7-1: 0]   adc_dat_b_ibuf  ;
	wire  [ 14-1: 0]  adc_dat_a_in    ;
	wire  [ 14-1: 0]  adc_dat_b_in    ;
	reg   [ 7-1: 0]   adc_dat_a_even  ;
    reg   [ 7-1: 0]   adc_dat_b_even  ;
	reg   [ 7-1: 0]   adc_dat_a_odd   ;
	reg   [ 7-1: 0]   adc_dat_b_odd   ;
	reg   [ 12-1: 0]  adc_data_a      ;
	reg   [ 12-1: 0]  adc_data_b      ;
	reg               adc_data_en     ;
    reg               i               ;

	genvar GV;
    
	generate
	  for (GV=0 ; GV<7 ; GV=GV+1) begin: adc_ipad
	     IBUFDS i_dat0 (.I (adc_data_p_a_i[GV]), .IB (adc_data_n_a_i[GV]), .O (adc_dat_a_ibuf[GV]));  // differential data input
	     IBUFDS i_dat1 (.I (adc_data_p_b_i[GV]), .IB (adc_data_n_b_i[GV]), .O (adc_dat_b_ibuf[GV]));  // differential data input
	  end
	endgenerate
	
	// the following remains to finish : seems to work but with warnings.
	
	generate
	always @(posedge adc_clk2d_i) begin
	   i = i+1;
	   if (i == 1) begin
	       adc_dat_a_odd <= adc_dat_a_ibuf ;
	       adc_dat_b_odd <= adc_dat_b_ibuf ;
	   end
	   else begin
	       adc_dat_a_even <= adc_dat_a_ibuf ;
	       adc_dat_b_even <= adc_dat_b_ibuf ;    
	   end
	end
	endgenerate

    generate
	   for (GV=0 ; GV<14 ; GV=GV+2) begin
	      assign adc_dat_a_in[GV] = adc_dat_a_even[GV/2] ;
	      assign adc_dat_a_in[GV+1] = adc_dat_a_odd[GV/2] ;
	      assign adc_dat_b_in[GV] = adc_dat_b_even[GV/2] ;
	      assign adc_dat_b_in[GV+1] = adc_dat_b_odd[GV/2] ;
	   end
	endgenerate



	always @(negedge adc_clk_i) begin
	   if (! resetn) begin
	      adc_data_en <= 0 ;
	      adc_data_a <= 0 ;
	      adc_data_b <= 0 ;
	   end
	   else begin
	      adc_data_en <= 1 ;

	      adc_data_a <= adc_dat_b_in[14-1:2] ; // switch adc_b->ch_a
	      adc_data_b <= adc_dat_a_in[14-1:2] ; // switch adc_a->ch_b
	   end
	end

endmodule

