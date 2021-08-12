module d_ff(clk, reset, D, Q);
	input clk, reset, D;
	output reg Q;

	always @(reset)
		if(!reset)
			Q <= 0;

	always @(posedge clk) begin
		if(!reset)
			Q <= 0;
		else
			Q <= D;
	end
endmodule
