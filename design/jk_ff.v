module jk_ff(clk, reset,J, K, Q, Q_bar);
	input clk, reset;
	input J,K;
	output Q, Q_bar;

	assign a = J & Q_bar;
	assign b = ~K & Q;
	assign c = a | b;

	d_ff dff(.D(c), .Q(Q), .Q_bar(Q_bar), .clk(clk), .reset(reset));

endmodule

