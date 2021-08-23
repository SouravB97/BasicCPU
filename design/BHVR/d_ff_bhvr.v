module d_ff(clk, reset, D, Q, Q_bar);
	input clk, reset, D;
	output reg Q;
	output wire Q_bar;

	assign Q_bar = ~Q;

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

module latch(D, EN, Q);
	input D, EN;
	output reg Q;

	always @(*) begin
		if(EN) Q <= D;
	end
endmodule
