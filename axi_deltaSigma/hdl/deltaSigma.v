/*
 * (c) Copyright: OscillatorIMP Digital
 * Author : Gwenhael Goavec-Merou<gwenhael.goavec-merou@trabucayre.com>
 * Creation date : 2019/02/01
*/

module deltaSigma #(
	parameter NB_BIT = 32
) (
	input		 clk_i,
	input		 rst_i,
	input		 trig_i,
	input [NB_BIT-1:0] data_i,
	output		 dac_o
);

localparam BIT_INT = NB_BIT+2;

wire [BIT_INT-1:0] data_in_s = {2'b0, data_i};

wire [BIT_INT-1:0] deltaB;
wire [BIT_INT-1:0] deltaAdder = $signed(data_in_s) + $signed(deltaB);

reg [BIT_INT-1:0] sigmaLatch;

wire [BIT_INT-1:0] sigmaAdder = $signed(deltaAdder) + $signed(sigmaLatch);

always @(posedge clk_i) begin
	if (rst_i)
		sigmaLatch <= 0;
	else if (trig_i)
		sigmaLatch <= sigmaAdder;
	else
		sigmaLatch <= sigmaLatch;
end

wire out_bit_s = sigmaLatch[BIT_INT-1];

assign deltaB = {out_bit_s, out_bit_s, {NB_BIT{1'b0}}};


reg dac_out_s;

always @(posedge clk_i) begin
	if (rst_i)
		dac_out_s <= 1'b0;
	else if (trig_i)
		dac_out_s <= out_bit_s;
	else
		dac_out_s <= dac_out_s;
end

assign dac_o = dac_out_s;

endmodule
