/*-----------------------------------------------------------------------
 * (c) Copyright: OscillatorIMP Digital
 * Author : Gwenhael Goavec-Merou<gwenhael.goavec-merou@trabucayre.com>
 * Creation date : 2017/05/27
 *-----------------------------------------------------------------------*/
module magnitude #(
	parameter DATA_SIZE = 16
) (
	// input data
	input [DATA_SIZE-1:0] data_i_i,
	input [DATA_SIZE-1:0] data_q_i,
	input                 data_en_i,
	input                 data_sof_i,
	input                 data_eof_i,
	input                 data_rst_i,
	input                 data_clk_i,
	// output data
	output [2*DATA_SIZE-1:0] data_o,
	output                  data_en_o,
	output                  data_sof_o,
	output                  data_eof_o,
	output                  data_rst_o,
	output                  data_clk_o
);

wire [2*DATA_SIZE-1:0] data_s = data_i_i * data_i_i + data_q_i * data_q_i;

always @(posedge data_clk_i) begin
	data_o <= data_s;
	data_en_o <= data_en_i;
	data_eof_o <= data_eof_i;
	data_sof_o <= data_sof_i;
end

assign data_clk_o = data_clk_i;
assign data_rst_o = data_rst_i;

endmodule
