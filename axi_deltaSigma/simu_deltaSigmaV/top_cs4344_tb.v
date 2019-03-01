`timescale 1ns / 100ps

module top_cs4344_tb;
`define DEBOUNCE_PER_MS 1
`define DEBOUNCE_PER_US 20
`define DATA_SIZE 16
`define ADDR_SIZE 3


///////////////////////////////////////////////////////////////////
//
// Local IOs and Vars
//

reg		clk = 0;
always #10 clk = ~clk;
reg 		rst_s;

localparam NB_BIT = 32;
reg [NB_BIT-1:0]	data_s;
reg					data_en_s;
wire				dac_s;

deltaSigma #(.NB_BIT(NB_BIT))
dS_inst(
    .clk_i(clk),
    .rst_i(rst_s),
    .trig_i(data_en_s),
    .data_i(data_s),
    //.data_i(truc_s),
    .dac_o(dac_s)
);

always @(posedge clk) begin
	if (rst_s)
		data_en_s <= 1'b0;
	else
		data_en_s <= !data_en_s;
end

reg [15:0] cpt_s ;
always @(posedge clk) begin
	if (rst_s) begin
		cpt_s <= 0;
		data_s <= 0;
	end else if (data_en_s) begin
		data_s <= data_s;
		if (cpt_s < 64)
			cpt_s <= cpt_s + 1;
		else begin
			cpt_s <= 0;
			if (data_s == {NB_BIT{1'b0}})
				data_s <= {1'b0, {NB_BIT-1{1'b1}}};
			else if (data_s == {NB_BIT{1'b1}})
				data_s <= {NB_BIT{1'b0}};
			else
				data_s <= {NB_BIT{1'b1}};
		end
	end else begin
		data_s <= data_s;
		cpt_s <= cpt_s;
	end
end
		

initial
   begin
	   $timeformat (-9, 1, " ns", 12);

		$display("INFO: Signal dump enabled ...\n\n");
		$dumpfile("simu/top_cs4344_tb.vcd");
		$dumpvars(0, top_cs4344_tb);
		$monitor("At time %t, value = %b %b %b %b",
		$time, data_en_s, cpt_s, data_s, dac_s);

		@(posedge clk);
		rst_s <= 1'b0;
		@(posedge clk);
		rst_s <= 1'b1;
	   	repeat(3) @(posedge clk);
		rst_s <= 1'b0;
	   	repeat(2)	@(posedge clk);
		@(posedge clk);
	   	repeat(500)	@(posedge clk);
		//wait (busy_s);
		//wait (!busy_s);
		wait_us(`DEBOUNCE_PER_US);
		wait_us(`DEBOUNCE_PER_US);
		wait_us(`DEBOUNCE_PER_US);
		wait_us(`DEBOUNCE_PER_US);
		wait_us(`DEBOUNCE_PER_US);
		wait_us(`DEBOUNCE_PER_US);
		wait_us(`DEBOUNCE_PER_US);
		wait_us(`DEBOUNCE_PER_US);
		wait_us(`DEBOUNCE_PER_US);
		wait_us(`DEBOUNCE_PER_US);
		wait_us(`DEBOUNCE_PER_US);
		wait_us(`DEBOUNCE_PER_US);
		wait_us(`DEBOUNCE_PER_US);
	   	#1 $finish;
   end

/* someusefull functions */
task wait_ms;
	input integer atime;
	begin
		repeat(atime) begin
			# 1_000_000;
		end
	end
endtask
task wait_us;
	input integer utime;
	begin
		repeat(utime) begin
			# 1_000;
		end
	end
endtask

endmodule

