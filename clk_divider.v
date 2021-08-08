//`include "C:/Users/soura/Documents/Verilog/testing/timescale.v"

module clk_divider(
	input clk_in,
	input reset,
	input [`DATA_WIDTH - 1:0] div_ratio,
	output reg clk_out
);
	
	real clk_in_period=1, clk_out_period=1;
	real t_start;


 	always @(reset) begin
 		if(!reset)	begin
 			clk_out <= 0;
 			t_start <= $time;
 		end
 	end
 
 	//update clk_out_period
 	always @(posedge clk_in) begin
		$display("posedge clk_in!!");
 		clk_in_period <= $time - t_start;
 		clk_out_period <= clk_in_period * (div_ratio +1);
 		t_start <= $time;
 		$display("CLK IN: Period = %f ns, Freq = %f MHz | CLK OUT Period = %f ns, Freq = %f MHz", clk_in_period, 1000/clk_in_period, clk_out_period, 1000/clk_out_period);
 	end
 
 	initial begin
 		$display("CLK IN: Period = %f ns, Freq = %f MHz | CLK OUT Period = %f ns, Freq = %f MHz", clk_in_period, 1000/clk_in_period, clk_out_period, 1000/clk_out_period);
 	end
 
 
 	always begin
 		clk_out = #(clk_out_period/2) 1'b0;
 		clk_out = #(clk_out_period/2) 1'b1;
 	end

endmodule
