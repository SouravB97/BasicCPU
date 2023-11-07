
/*

|--------------------------------------------------------------|
|OPCODE |HEX			 |NAME		|OPERATION			|Function            |
|--------------------------------------------------------------|
|00000	|'h00			 		 |LD 		|C = A					|Transfer A          |
|00001	|'h01			 		 |INC		|C = A + 1;			|Increment A         |
|00010	|'h02			 		 |ADD		|C = A + B;			|Addition            |
|00011	|'h03			 		 |ADC		|C = A + B + 1;	|Add with carry      |
|00100	|'h04			 		 |SBB		|C = A + ~B;		|Subtract with borrow|
|00101	|'h05			 		 |SUB		|C = A + ~B + 1;|Subtraction         |
|00110	|'h06			 		 |DEC		|C = A - 1;			|Decrement A         |
|00111	|'h07			 		 |LD1		|C = A;					|Transfer A          |
|0100x	|'h08,'h09		 |AND		|C = A & B;			|AND                 |
|0101x	|'h0A,'h0B		 |OR 		|C = A | B;			|OR                  |
|0110x	|'h0C,'h0D		 |XOR		|C = A ^ B;			|XOR                 |
|0111x	|'h0E,'h0F		 |CMP		|C = ~B;				|Complement A        |
|10xxx	|'h10-'h17		 |LSH		|C = A >> 1;		|Shift right         |
|11xxx	|'h18-'h1F		 |RSH		|C = A << 1;		|Shift left          |
|-------------------------|------------------------------------|

*/

`define LD				'h00
`define INC				'h01
`define ADD				'h02
`define ADC				'h03
`define SBB				'h04
`define SUB				'h05
`define DEC				'h06
`define LD1				'h07
`define AND				'h08
`define OR				'h0A
`define XOR				'h0C
`define CMP				'h0E
`define LSH				'h10
`define RSH				'h18

//`include "ALU_components.v"

module ALU
#(parameter DATA_WIDTH = `DATA_WIDTH)(
	input[DATA_WIDTH -1:0] A,B,
	input[4:0] opcode,
	output[DATA_WIDTH-1:0] C,
	output[3:0] status 
);
	wire sign, zero, parity, carry;
	wire [DATA_WIDTH-1:0] w1,w2,w3,w4;

	assign status = {sign, zero, parity, carry};

	AU #(.DATA_WIDTH(DATA_WIDTH)) aui(	
		.A(A), .B(B),
		.opcode(opcode[2:0]),
		.Cout(carry_AU),
		.S(w1)
	);

	LU #(.DATA_WIDTH(DATA_WIDTH)) lui(
		.A(A), .B(B),
		.opcode(opcode[2:1]),
		.S(w2)
	);

	SHU #(.DATA_WIDTH(DATA_WIDTH)) shui(
		.A(A), 
		.opcode(opcode[3]),
		.C(w3),
		.Cout(carry_SHU)
	);

	genvar i;
	generate
		for(i = 0; i < DATA_WIDTH; i = i+1) begin

			mux #(.SIZE(2)) m1 (.D({w2[i], w1[i]}), .S(opcode[3]), .Y(w4[i]));
			mux #(.SIZE(2)) m2 (.D({w3[i], w4[i]}), .S(opcode[4]), .Y(C[i]));

		end
	endgenerate

	//assign status bits
	assign sign 	= C[DATA_WIDTH-1]; //MSB
	assign zero 	= ~|C;	//C==0?
	assign parity = ^C; //EVEN parity
	assign carry  = carry_AU | carry_SHU; //Carry is set when data overflow or underflow occurs

endmodule
