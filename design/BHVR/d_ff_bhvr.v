module d_ff(clk, reset, D, Q, Q_bar);
	input clk, reset, D;
	output Q_bar;
	output reg Q;

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

module latch
#(parameter DATA_WIDTH = 1)(
	input [DATA_WIDTH-1:0] D,
	input EN,
	output reg [DATA_WIDTH-1:0] Q
);
	always @(*) begin
		if(EN)
			Q = D;
	end
endmodule
