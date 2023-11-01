//`define DFF_BHVR

`ifndef DFF_BHVR
module d_ff(clk, reset, D, Q, Q_bar);
	input clk, reset, D;
	output Q, Q_bar;

	assign Q_bar = q_bar;

//edge triggered
	//master stage
	and a1(a, D, ~clk);
	and a2(b, ~clk, ~D);
	nor n1(c,a,d);
	nor n2(d,c,b);

	//slave stage
	and a3(e, c, clk);
	and a4(f, clk, d);

	//reset or gate
	or o1(g, ~reset, e);
	and a5(h, reset, f);

	nor n3(Q, g, q_bar);
	nor n4(q_bar, Q, h);

endmodule

module latch(D, EN, Q);
	input D, EN;
	output Q;

	//level triggered
	nand u1(Q, A, q_bar);
	nand u2(q_bar, Q, B);
	nand u3(A, D, EN);
	nand u4(B, ~D, EN);

endmodule
`else
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

module latch(D, EN, Q);
	input D, EN;
	output reg Q;

	always @(*) begin
		if(EN)
			Q = D;
	end
endmodule
`endif
