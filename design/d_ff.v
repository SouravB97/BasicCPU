
module d_ff(clk, reset, D, Q, Q_bar);
	input clk, reset, D;
	output Q, Q_bar;

	assign Q_bar = q_bar;

	//edge triggered
	and a1(a, D, ~clk);
	and a2(b, ~clk, ~D);
	nor n1(c, a, d);
	nor n2(d, c, b);

	and a3(e, c, clk);
	and a4(f, clk, d);

	or o1(g, ~reset, e);
	and a5(h, reset, f);

	nor n3(Q, g, q_bar);
	nor n4(q_bar, Q, h);

endmodule

module latch(D, EN, Q);
	input D, EN;
	output Q;

	//Level triggered
	nand u1(A, D, EN);
	nand u2(B, ~D, EN);
	nand u5(Q, A, Q_bar);
	nand u6(Q_bar, B, Q);

endmodule
