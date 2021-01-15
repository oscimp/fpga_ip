/*-----------------------------------------------------------------------
 * (c) Copyright: OscillatorIMP Digital
 * Author : Gwenhael Goavec-Merou<gwenhael.goavec-merou@trabucayre.com>
 * Creation date : 2017/05/27
 *-----------------------------------------------------------------------*/
module cplx_conj #(
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
	output [DATA_SIZE-1:0] data_i_o,
	output [DATA_SIZE-1:0] data_q_o,
	output                 data_en_o,
	output                 data_sof_o,
	output                 data_eof_o,
	output                 data_rst_o,
	output                 data_clk_o
);

assign data_i_o = data_i_i;
assign data_q_o = -data_q_i;

assign data_clk_o = data_clk_i;
assign data_eof_o = data_eof_i;
assign data_sof_o = data_sof_i;
assign data_rst_o = data_rst_i;
assign data_en_o  = data_en_i;

endmodule
