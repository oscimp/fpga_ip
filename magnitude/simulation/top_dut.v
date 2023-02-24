`timescale 1ns / 100ps

module top_dut (
	input         clk_i,
	input         rst_i,
	input  [9:0] data_i_i,
	input  [9:0] data_q_i,
	input         data_en_i,
	output [20:0] data_uns_o,
	output        data_uns_en_o,
	output [20:0] data_sign_o,
	output        data_sign_en_o
);
	magnitude #(.SIGN_CORRECTION(0), .DATA_SIZE(10)
	) magnitude_uns (
        .data_clk_i(clk_i), .data_rst_i(rst_i),
		.data_i_i(data_i_i), .data_q_i(data_q_i), .data_en_i(data_en_i),
		.data_eof_i(1'b0), .data_sof_i(1'b0),
		.data_o(data_uns_o), .data_en_o(data_uns_en_o), .data_eof_o(), .data_sof_o()
	);

	magnitude #(.SIGN_CORRECTION(1), .DATA_SIZE(10)
	) magnitude_sign (
        .data_clk_i(clk_i), .data_rst_i(rst_i),
		.data_i_i(data_i_i), .data_q_i(data_q_i), .data_en_i(data_en_i),
		.data_eof_i(1'b0), .data_sof_i(1'b0),
		.data_o(data_sign_o), .data_en_o(data_sign_en_o), .data_eof_o(), .data_sof_o()
	);

`ifdef COCOTB_SIM
	initial begin
		$dumpfile("magnitude_simu_tb.vcd");
		$dumpvars(0, top_dut);
		#1;
   end
`endif
endmodule

