
module d_ff(clk, reset, D, Q);
	input clk, reset, D;
	output reg Q;

	always @(reset) begin
		if(!reset)
			Q <= 0;
	end

	always @(posedge clk) begin
			Q <= D;
			//Q <= #0.01 D;
	end

endmodule
