/*-----------------------------------------------------------------------
 * (c) Copyright: OscillatorIMP Digital
 * Author : Gwenhael Goavec-Merou<gwenhael.goavec-merou@trabucayre.com>
 * Creation date : 2017/05/27
 *-----------------------------------------------------------------------*/
module magnitude #(
	parameter SIGN_CORRECTION = 0,
	parameter DATA_SIZE = 16
) (
	// input data
	input      [DATA_SIZE-1:0] data_i_i,
	input      [DATA_SIZE-1:0] data_q_i,
	input                      data_en_i,
	input                      data_sof_i,
	input                      data_eof_i,
	input                      data_rst_i,
	input                      data_clk_i,
	// output data
	output reg [2*DATA_SIZE:0] data_o,
	output reg                 data_en_o,
	output reg                 data_sof_o,
	output reg                 data_eof_o,
	output                     data_rst_o,
	output                     data_clk_o
);

wire [2*DATA_SIZE-1:0] data_i_s = $signed(data_i_i) * $signed(data_i_i);
wire [2*DATA_SIZE-1:0] data_q_s = $signed(data_q_i) * $signed(data_q_i);

wire [2*DATA_SIZE  :0] data_s   = (data_i_s) + (data_q_s);
wire                   sign_s   = (SIGN_CORRECTION == 1) & data_q_i[DATA_SIZE-1];

always @(posedge data_clk_i) begin
	data_o <= (sign_s == 1'b0) ? data_s : -$signed(data_s);
	data_en_o <= data_en_i;
	data_eof_o <= data_eof_i;
	data_sof_o <= data_sof_i;
end

assign data_clk_o = data_clk_i;
assign data_rst_o = data_rst_i;

endmodule
