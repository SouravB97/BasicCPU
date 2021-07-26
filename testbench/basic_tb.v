`include "includes.v"

module basic_tb();
	reg clk, reset;

	parameter clk_period = 10;
	integer i;

	always #(clk_period/2) clk = ~clk;

	initial begin
		$dumpfile("basic_tb.vcd");
		$dumpvars(0,basic_tb);
		$timeformat(-9, 2, " ns", 20);
		$printtimescale;

		#10 reset = 1'b1;
	end

endmodule
