
/*

|--------------------------------------------------------------|
|OPCODE |HEX			 |NAME	|OPERATION			|Function            |
|--------------------------------------------------------------|
|00000	|'h00			 |LD 		|C = A					|Transfer A          |
|00001	|'h01			 |INC		|C = A + 1;			|Increment A         |
|00010	|'h02			 |ADD		|C = A + B;			|Addition            |
|00011	|'h03			 |ADC		|C = A + B + 1;	|Add with carry      |
|00100	|'h04			 |SBB		|C = A + ~B;		|Subtract with borrow|
|00101	|'h05			 |SUB		|C = A + ~B + 1;|Subtraction         |
|00110	|'h06			 |DEC		|C = A - 1;			|Decrement A         |
|00111	|'h07			 |LD1		|C = A;					|Transfer A          |
|0100x	|'h08,'h09 |AND		|C = A & B;			|AND                 |
|0101x	|'h0A,'h0B |OR 		|C = A | B;			|OR                  |
|0110x	|'h0C,'h0D |XOR		|C = A ^ B;			|XOR                 |
|0111x	|'h0E,'h0F |CMP		|C = ~B;				|Complement A        |
|10xxx	|'h10-'h17 |LSH		|C = A >> 1;		|Shift right         |
|11xxx	|'h18-'h1F |RSH		|C = A << 1;		|Shift left          |
|-------------------------|------------------------------------|

*/
`define ALU_BHVR
`ifdef ALU_BHVR

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

module ALU
	(
	input[4:0] opcode,
	input[`DATA_WIDTH -1:0] A,B,
	output[`DATA_WIDTH-1:0] C,
	output[3:0] status 
);
	reg [`DATA_WIDTH:0] output_c;
	wire Cin = opcode[0];
	wire [3:0] S = opcode[3:1];
	wire sign, zero, parity, carry;
	assign status = {sign, zero, parity, carry};

	//assign status bits
	assign sign 	= C[`DATA_WIDTH-1];
	assign zero 	= (C == 0);
	assign parity = ^C; //EVEN parity
	assign carry	= output_c[`DATA_WIDTH];

	assign C = output_c;

	always @(*) begin
		case(opcode)
			'h00: output_c <= A;
			'h01:	output_c <= A+1;
			'h02: output_c <= A+B;
			'h03:	output_c <= A + B + 1; 
			'h04:	output_c <= A + ~B;		 
			'h05:	output_c <= A + ~B + 1;
			'h06:	output_c <= A - 1;		 
			'h07:	output_c <= A;				 
			'h08,'h09: output_c <= A & B;		 
			'h0A,'h0B: output_c <= A | B;		 
			'h0C,'h0D: output_c <= A ^ B;		 
			'h0E,'h0F: output_c <= ~B;				 
			//'b10???: output_c <= A >> 1;		 
			//'b11???: output_c <= A << 1;		 
			default: begin
				if(opcode[4:3] == 'b10) output_c = A >> 1;
				if(opcode[4:3] == 'b11) output_c = A << 1;
			end
		endcase
	end

endmodule
`endif //ALU_BHVR
