module half_adder (
	input A, B,
	output S, Cout
);
	assign Cout = A&B;
	assign S = A^B;
endmodule

module full_adder(
	input A, B, Cin,
	output S, Cout
);
	wire w1, w2, w3;

	half_adder h1(.A(A), .B(B), .S(w1), .Cout(w2));
	half_adder h2(.A(w1), .B(Cin), .S(S), .Cout(w3));

	assign Cout = w2 | w3;

endmodule

//shift circuit
//	OPCODE OPERATION 
//	0 LSH
//	1 RSH
module SHU
#(parameter DATA_WIDTH = `DATA_WIDTH)(
	input [DATA_WIDTH-1:0] A,
	input opcode,
	output [DATA_WIDTH-1:0] C,
	output Cout
);

	genvar i;
	//instance 0
	mux #(.DATA_WIDTH(2)) m0(.D({1'b0,A[1]}), .S(opcode), .Y(C[0]));

	//instance i
	generate
		for(i = 1; i<DATA_WIDTH-1; i=i+1) begin
			mux #(.DATA_WIDTH(2)) mi(.D({A[i-1], A[i+1]}), .S(opcode), .Y(C[i]));
		end
	endgenerate

	//instance n-1
	mux #(.DATA_WIDTH(2)) mn1(.D({A[DATA_WIDTH-2], 1'b0}), .S(opcode), .Y(C[DATA_WIDTH-1]));

	//for generating carry
	mux #(.DATA_WIDTH(2)) mux_carry(.D({A[DATA_WIDTH-1], 1'b0}), .S(opcode), .Y(Cout));
endmodule

//logic circuit
//	OPCODE OPERATION
//	00	AND	
//	01	OR
//	10	XOR
//	11	NOT
module LU
#(parameter DATA_WIDTH = `DATA_WIDTH)(
	input [DATA_WIDTH-1:0] A,B,
	input [1:0] opcode,
	output [DATA_WIDTH-1:0] S
);
	wire [DATA_WIDTH-1:0] a,o,x,n;

	assign a = A & B;
	assign o = A | B;
	assign x = A ^ B;
	assign n = ~A;

	genvar i;
	generate
		for(i = 0; i< DATA_WIDTH; i=i+1) begin
			//mux #(.DATA_WIDTH(4)) m1(.D({a[i],o[i],x[i],n[i]}), .S(opcode), .Y(S[i]));
			mux #(.DATA_WIDTH(4)) m1(.D({n[i],x[i],o[i],a[i]}), .S(opcode), .Y(S[i]));
		end
	endgenerate
endmodule

//arithmatic circuit
//  OPCODE	OPERATION
//  000	0		S = A+B
//  001	1		S = A+B+1
//  010	2		S = A+~B (A-B+1)
//  011	3		S = A +~B + 1 (A-B)
//  100	4		S = A
//  101	5		S = A+1
//  110	6		S = A-1
//  111	7		S = A


//|OPCODE |HEX			 |NAME	|OPERATION			|Function            |
//|--------------------------------------------------------------|
//|000		|'h00			 |LD 		|S = A					|Transfer A          |
//|001		|'h01			 |INC		|S = A + 1;			|Increment A         |
//|010		|'h02			 |ADD		|S = A + B;			|Addition            |
//|011		|'h03			 |ADC		|S = A + B + 1;	|Add with carry      |
//|100		|'h04			 |SBB		|S = A + ~B;		|Subtract with borrow|
//|101		|'h05			 |SUB		|S = A + ~B + 1;|Subtraction         |
//|110		|'h06			 |DEC		|S = A - 1;			|Decrement A         |
//|111		|'h07			 |LD1		|S = A;					|Transfer A          |

module AU
#(parameter DATA_WIDTH = `DATA_WIDTH)(
	input [DATA_WIDTH -1:0] A, B,
	input [2:0] opcode,
	output [DATA_WIDTH-1:0] S,
	output Cout
);
	wire[DATA_WIDTH:0] c;
	wire[DATA_WIDTH-1:0] w1;
	wire Cin;

	assign Cin = opcode[0];
	assign c[0] = Cin;
	assign Cout = c[DATA_WIDTH];

	genvar i;
	generate
		for(i =0; i< DATA_WIDTH; i = i+1) begin
			full_adder fa(.A(A[i]), .B(w1[i]), .Cin(c[i]), .S(S[i]), .Cout(c[i+1]));	
			//mux #(.DATA_WIDTH(4)) m1(.D({B[i], ~B[i], 1'b1, 1'b0}),.S(opcode[2:1]),.Y(w1[i]));
			mux #(.DATA_WIDTH(4)) m1(.D({1'b1,~B[i],B[i],1'b0}),.S(opcode[2:1]),.Y(w1[i]));
		end
	endgenerate
	
endmodule

