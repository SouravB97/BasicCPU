`include "includes.vh"

module basic_tb();
	localparam dump_file = "basic_tb.vcd";
	reg clk, reset;
	reg [`DATA_WIDTH - 1:0] div_ratio;
	wire clk_out;

	parameter clk_period = 10;
	integer i;

	always #(clk_period/2) clk = ~clk;

	//instantiate DUT

	initial begin
		$dumpfile(dump_file);
		$dumpvars(0,basic_tb);
		$timeformat(-9, 2, " ns", 20);

		clk <=0;
		reset <=0;
		div_ratio <= 0;
		$printtimescale;

		#10 reset = 1'b1;
	end


	initial begin
		#100;
		for(i = 0; i < 10; i = i+1) begin
			#100 div_ratio = i;
			//$display("Time = %t, div_ratio = %d",$time, div_ratio);
		end
		$finish();
	end

	initial begin
		$monitor("Time = %0t /t  = %b",$time, div_ratio);
	end

endmodule
