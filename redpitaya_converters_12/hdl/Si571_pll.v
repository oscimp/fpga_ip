module Si571_pll (
	// Data input
	input           pll_cfg_en   ,
	input           pll_ref_i    ,
	output		    pll_hi_o     ,
	output		    pll_lo_o     ,
	input           clk_i        ,
	input           clk_10mhz    ,
	input           rstn_i    

);


//---------------------------------------------------------------------------------
//
//  Simple FF PLL 

// detect RF clock
reg  [16-1:0] pll_ref_cnt = 16'h0;
reg  [ 3-1:0] pll_sys_syc  ;
reg  [21-1:0] pll_sys_cnt  ;
reg           pll_sys_val  ;
//reg           pll_cfg_en   ;
wire [32-1:0] pll_cfg_rd   ;

always @(posedge pll_ref_i) begin
  pll_ref_cnt <= pll_ref_cnt + 16'h1;
end

always @(posedge clk_i) 
if (rstn_i == 1'b0) begin
  pll_sys_syc <=  3'h0 ;
  pll_sys_cnt <= 21'h100000;
  pll_sys_val <=  1'b0 ;
end else begin
  pll_sys_syc <= {pll_sys_syc[3-2:0], pll_ref_cnt[14-1]} ;

  if (pll_sys_syc[3-1] ^ pll_sys_syc[3-2])
    pll_sys_cnt <= 21'h1;
  else if (!pll_sys_cnt[21-1])
    pll_sys_cnt <= pll_sys_cnt + 21'h1;

  // pll_sys_clk must be around 102400 (125000000/(10000000/2^13))
  if (pll_sys_syc[3-1] ^ pll_sys_syc[3-2])
    pll_sys_val <= (pll_sys_cnt > 102385) && (pll_sys_cnt < 102415) ;
  else if (pll_sys_cnt[21-1])
    pll_sys_val <= 1'b0 ;
end


reg  pll_ff_sys ;
reg  pll_ff_ref ;
wire pll_ff_rst ;
wire pll_ff_lck ;

// FF PLL functionality
always @(posedge clk_10mhz or negedge pll_ff_rst) begin
  if (!pll_ff_rst)  pll_ff_sys <= 1'b0 ;
  else              pll_ff_sys <= 1'b1 ;
end
always @(posedge pll_ref_i or negedge pll_ff_rst) begin
  if (!pll_ff_rst)  pll_ff_ref <= 1'b0 ;
  else              pll_ff_ref <= 1'b1 ;
end
assign pll_ff_rst = !(pll_ff_sys && pll_ff_ref) ;
assign pll_ff_lck = (!pll_ff_sys && !pll_ff_ref);

assign pll_lo_o = !pll_ff_sys && ( pll_sys_val &&  pll_cfg_en);
assign pll_hi_o =  pll_ff_ref || (!pll_sys_val || !pll_cfg_en);

endmodule
