
module jk_ff(clk, reset, J, K, Q, Q_bar);
	input clk, reset;
	input J,K;
	output Q, Q_bar;

	and u1(a, J, Q_bar);
	and u2(b, ~K, Q);

	or u3(c, a, b);

	d_ff dff(.D(c), .Q(Q), .Q_bar(Q_bar), .clk(clk), .reset(reset));

endmodule
