`include "C:/Users/soura/Documents/Verilog/testing/timescale.v"

`include "../clk_divider.v"

module clk_divider_tb();
	reg clk, reset;
	reg [`DATA_WIDTH - 1:0] div_ratio;
	wire clk_out;

	parameter clk_period = 10;
	integer i;


	always #(clk_period/2) clk = ~clk;

	initial begin
		$dumpfile("clk_divider_tb.vcd");
		$dumpvars(0,clk_divider_tb);
		$timeformat(-9, 2, " ns", 20);

		clk <=0;
		reset <=0;
		div_ratio <= 0;
		$printtimescale;

		#10 reset = 1'b1;
	end

	clk_divider clk_div(
		.clk_in(clk),
		.reset(reset),
		.div_ratio(div_ratio),
		.clk_out(clk_out)
	);



	initial begin
		#100;
		for(i = 0; i < 10; i = i+1) begin
			#100 div_ratio = i;
			$display("Time = %t, div_ratio = %d",$time, div_ratio);
		end
		$finish();
	end

//	initial begin
//		$monitor("Time = %0t /t  = %b",$time, clk_div.div_ratio);
//	end

endmodule
