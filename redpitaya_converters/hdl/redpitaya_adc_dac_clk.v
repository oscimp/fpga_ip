module redpitaya_adc_dac_clk
(
  input             adc_clk_p_i        ,  //!< ADC IC clock P connection
  input             adc_clk_n_i        ,  //!< ADC IC clock N connection
  
  output			dac_clk_o,
  output			dac_2clk_o,
  output			dac_2ph_o,
  output			dac_locked_o,
  output            adc_clk_o          ,  //!< ADC clock
  output 			adc_rstn_o,
  output 			adc_rst_o,
  input             adc_rst_i        ,  //!< ADC reset - active high
  output            ser_clk_o           //!< fast serial clock
);


//---------------------------------------------------------------------------------
//
//  ADC input registers

wire           adc_clk_in ;
wire           adc_clk    ;

IBUFDS i_clk ( .I(adc_clk_p_i), .IB(adc_clk_n_i), .O(adc_clk_in));  // differential clock input
BUFG i_adc_buf  (.O(adc_clk), .I(adc_clk_in)); // use global clock buffer

assign adc_clk_o   =  adc_clk ;
assign dac_clk_o = dac_clk;
assign dac_2clk_o = dac_2clk;
assign dac_2ph_o = dac_2ph;
assign dac_locked_o = dac_locked;

//---------------------------------------------------------------------------------
//
//  Fast DAC - DDR interface

wire  dac_clk_fb      ;
wire  dac_clk_fb_buf  ;
wire  dac_clk_out     ;
wire  dac_2clk_out    ;
wire  dac_clk         ;
wire  dac_2clk        ;
wire  dac_locked      ;
reg   dac_rst         ;
wire  ser_clk_out     ;
wire  dac_2ph_out     ;
wire  dac_2ph         ;

PLLE2_ADV
#(
   .BANDWIDTH            ( "OPTIMIZED"   ),
   .COMPENSATION         ( "ZHOLD"       ),
   .DIVCLK_DIVIDE        (  1            ),
   .CLKFBOUT_MULT        (  8            ),
   .CLKFBOUT_PHASE       (  0.000        ),
   .CLKOUT0_DIVIDE       (  8            ),
   .CLKOUT0_PHASE        (  0.000        ),
   .CLKOUT0_DUTY_CYCLE   (  0.5          ),
   .CLKOUT1_DIVIDE       (  4            ),
   .CLKOUT1_PHASE        (  0.000        ),
   .CLKOUT1_DUTY_CYCLE   (  0.5          ),
   .CLKOUT2_DIVIDE       (  4            ),
   .CLKOUT2_PHASE        ( -45.000       ),
   .CLKOUT2_DUTY_CYCLE   (  0.5          ),
   .CLKOUT3_DIVIDE       (  4            ),  // 4->250MHz, 2->500MHz
   .CLKOUT3_PHASE        (  0.000        ),
   .CLKOUT3_DUTY_CYCLE   (  0.5          ),
   .CLKIN1_PERIOD        (  8.000        ),
   .REF_JITTER1          (  0.010        )
)
i_dac_plle2
(
   // Output clocks
   .CLKFBOUT     (  dac_clk_fb     ),
   .CLKOUT0      (  dac_clk_out    ),
   .CLKOUT1      (  dac_2clk_out   ),
   .CLKOUT2      (  dac_2ph_out    ),
   .CLKOUT3      (  ser_clk_out    ),
   .CLKOUT4      (        ),
   .CLKOUT5      (        ),
   // Input clock control
   .CLKFBIN      (  dac_clk_fb_buf ),
   .CLKIN1       (  adc_clk        ),
   .CLKIN2       (  1'b0           ),
   // Tied to always select the primary input clock
   .CLKINSEL     (  1'b1           ),
   // Ports for dynamic reconfiguration
   .DADDR        (  7'h0           ),
   .DCLK         (  1'b0           ),
   .DEN          (  1'b0           ),
   .DI           (  16'h0          ),
   .DO           (        ),
   .DRDY         (        ),
   .DWE          (  1'b0           ),
   // Other control and status signals
   .LOCKED       (  dac_locked     ),
   .PWRDWN       (  1'b0           ),
   .RST          ( adc_rst_i       )
);

BUFG i_dacfb_buf   (.O(dac_clk_fb_buf), .I(dac_clk_fb));
BUFG i_dac1_buf    (.O(dac_clk),        .I(dac_clk_out));
BUFG i_dac2_buf    (.O(dac_2clk),       .I(dac_2clk_out));
BUFG i_dac2ph_buf  (.O(dac_2ph),        .I(dac_2ph_out));
BUFG i_ser_buf     (.O(ser_clk_o),      .I(ser_clk_out));

	localparam STAGES = 3,
    INITIAL_VAL = 1'b1;

  // Synchronize asynchronous reset and MIMO
   (* ASYNC_REG = "TRUE" *) reg value[0:STAGES-1];

   integer k;
   initial begin
     for (k = 0; k < STAGES; k = k + 1) begin
       value[k] = INITIAL_VAL;
     end
   end

   genvar i;
   generate
      for (i=0; i<STAGES; i=i+1) begin: stages
         always @(posedge adc_clk) begin
         	if (i == 0) begin
            	value[i] <= 1'b0;
            end else begin
            	value[i] <= value[i-1];
            end
         end
      end
   endgenerate

  assign adc_rstn_o = ~value[STAGES-1];
  assign adc_rst_o = value[STAGES-1];



endmodule

