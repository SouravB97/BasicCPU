/*
Address map:

RAM: 0x0000-0x00FF
IO:  0x8000-0x8004
*/
	/*
		SID	|	Register
		0 	|	IR0	
		1 	|	Mem 
		2 	|	A
		3 	|	B
		4 	|	AR0
		5 	|	AR1 
		6 	| PC0      
		7 	| PC1      
		8 	|	IR1
		9 	| R0	
		10	|	R1
		11	|	SP0
		12	|	SP1
		13	|	PORTA
		14	|	PORTB
		15	|	PORTC
		16	|	PORTD

		MID	|	Register
		0 	|	IR0	
		1 	|	Mem 
		2 	|	A
		3 	|	B
		4 	|	AR0
		5 	|	AR1 
		6 	| PC0      
		7 	| PC1      
		8 	|	IR1
		9 	| R0	
		10	|	R1
		11	|	SP0
		12	|	SP1
		13	|	PORTA
		14	|	PORTB
		15	|	PORTC
		16	|	PORTD
		17	|	SR
		18	|	ALU
	*/
`define CB_SID_EN_RANGE					0:0  
`define CB_MID_EN_RANGE					1:1  
`define CB_PC_INR_RANGE					2:2  
`define CB_AMID_RANGE						4:3  
`define CB_MID_RANGE						8:5  
`define CB_SID_RANGE					 12:9  
`define CB_ALU_OPCODE_RANGE		 17:13  
`define CB_HLT_RANGE	 				 18:18  
`define CB_CLR_TIMER_RANGE	 	 19:19  
`define CB_EN_ALU_RANGE	 	 		 20:20  
`define CB_AR_INR_RANGE	 	 		 21:21  

`define DEC_OP(op) \ //gives same output as ir0_decoder
	(op >> `OPCODEWORD_DECODE_OFFSET)	& {`OPCODEWORD_ALU_OPCODE_WIDTH{1'b1}}
`define IS_MOV(op) (op >> `OPCODEWORD_TYPE_OFFSET) ^ 2'b00
`define IS_MV1(op) (op >> `OPCODEWORD_TYPE_OFFSET) ^ 2'b01
`define IS_ALU(op) (op >> `OPCODEWORD_TYPE_OFFSET) ^ 2'b10
`define IS_SYS(op) (op >> `OPCODEWORD_TYPE_OFFSET) ^ 2'b11

`define OPCODEWORD_TYPE_RANGE			7:6
`define OPCODEWORD_ALU_OPCODE_RANGE			4:0
`define OPCODEWORD_DECODE_RANGE					`OPCODEWORD_ALU_OPCODE_RANGE
`define OPCODEWORD_MID_RANGE			2:0
`define OPCODEWORD_SID_RANGE			5:3

`define OPCODEWORD_TYPE_OFFSET					6
`define OPCODEWORD_ALU_OPCODE_OFFSET		0
`define OPCODEWORD_DECODE_OFFSET				`OPCODEWORD_ALU_OPCODE_OFFSET

`define OPCODEWORD_ALU_OPCODE_WIDTH 		5

//MVI instruction
`define CPU_INSTR_LDA 				 8'b0101_0001	//0x11
`define CPU_INSTR_LDB 				 8'b0101_1001	//0x19
`define CPU_INSTR_LAR0 				 8'b0110_0001	//0x21
`define CPU_INSTR_LAR1 				 8'b0110_1001	//0x29
`define CPU_INSTR_LPC0 				 8'b0111_0001	//0x31
`define CPU_INSTR_LPC1 				 8'b0111_1001	//0x39

`define CPU_INSTR_STA 				 8'b0000_1010	//0x0A
`define CPU_INSTR_STB 				 8'b0000_1011	//0x0B
`define CPU_INSTR_SAR0 				 8'b0000_1100	//0x0C
`define CPU_INSTR_SAR1 				 8'b0000_1101	//0x0D
`define CPU_INSTR_SPC0 				 8'b0000_1110	//0x0E
`define CPU_INSTR_SPC1 				 8'b0000_1111	//0x0F

//MOV_SRC_DST								sid_mid
`define CPU_INSTR_MOV_MEM_A		 	 8'b00010001
`define CPU_INSTR_MOV_MEM_B			 8'b00011001
`define CPU_INSTR_MOV_MEM_AR0		 8'b00100001
`define CPU_INSTR_MOV_MEM_AR1		 8'b00101001
`define CPU_INSTR_MOV_MEM_PC0		 8'b00110001
`define CPU_INSTR_MOV_MEM_PC1		 8'b00111001

`define CPU_INSTR_MOV_A_MEM		 8'b0000_1010
`define CPU_INSTR_MOV_A_B			 8'b0001_1010
`define CPU_INSTR_MOV_A_AR0		 8'b0010_0010
`define CPU_INSTR_MOV_A_AR1		 8'b0010_1010
`define CPU_INSTR_MOV_A_PC0		 8'b0011_0010
`define CPU_INSTR_MOV_A_PC1		 8'b0011_1010

`define CPU_INSTR_MOV_B_MEM		 8'b0000_1011
`define CPU_INSTR_MOV_B_A			 8'b0001_0011
`define CPU_INSTR_MOV_B_AR0		 8'b0010_0011
`define CPU_INSTR_MOV_B_AR1		 8'b0010_1011
`define CPU_INSTR_MOV_B_PC0		 8'b0011_0011
`define CPU_INSTR_MOV_B_PC1		 8'b0011_1011
                                
`define CPU_INSTR_MOV_AR0_MEM		 8'b00001100
`define CPU_INSTR_MOV_AR0_A		 	 8'b00010100
`define CPU_INSTR_MOV_AR0_B			 8'b00011100
`define CPU_INSTR_MOV_AR0_AR1		 8'b00101100
`define CPU_INSTR_MOV_AR0_PC0		 8'b00110100
`define CPU_INSTR_MOV_AR0_PC1		 8'b00111100

`define CPU_INSTR_MOV_AR1_MEM		 8'b00001101
`define CPU_INSTR_MOV_AR1_A		 	 8'b00010101
`define CPU_INSTR_MOV_AR1_B			 8'b00011101
`define CPU_INSTR_MOV_AR1_AR0		 8'b00100101
`define CPU_INSTR_MOV_AR1_PC0		 8'b00110101
`define CPU_INSTR_MOV_AR1_PC1		 8'b00111101

`define CPU_INSTR_MOV_PC0_MEM		 8'b00001110
`define CPU_INSTR_MOV_PC0_A		 	 8'b00010110
`define CPU_INSTR_MOV_PC0_B			 8'b00011110
`define CPU_INSTR_MOV_PC0_AR0		 8'b00100110
`define CPU_INSTR_MOV_PC0_AR1		 8'b00101110
`define CPU_INSTR_MOV_PC0_PC1		 8'b00111110

`define CPU_INSTR_MOV_PC1_MEM		 8'b00001111
`define CPU_INSTR_MOV_PC1_A		 	 8'b00010111
`define CPU_INSTR_MOV_PC1_B			 8'b00011111
`define CPU_INSTR_MOV_PC1_AR0		 8'b00100111
`define CPU_INSTR_MOV_PC1_AR1		 8'b00101111
`define CPU_INSTR_MOV_PC1_PC0		 8'b00110111


//ALU instructions
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
`define CPU_INSTR_LD  				 8'b1000_0000
`define CPU_INSTR_INC 				 8'b1000_0001
`define CPU_INSTR_ADD 				 8'b1000_0010
`define CPU_INSTR_ADC 				 8'b1000_0011
`define CPU_INSTR_SBB 				 8'b1000_0100
`define CPU_INSTR_SUB 				 8'b1000_0101
`define CPU_INSTR_DEC 				 8'b1000_0110
`define CPU_INSTR_LD1 				 8'b1000_0111
`define CPU_INSTR_AND 				 8'b1000_1000
`define CPU_INSTR_OR	 				 8'b1000_1010
`define CPU_INSTR_XOR 				 8'b1000_1100
`define CPU_INSTR_CMP 				 8'b1000_1110
`define CPU_INSTR_LSH 				 8'b1001_0000
`define CPU_INSTR_RSH 				 8'b1001_1000

//SYSTEM instructions
`define CPU_INSTR_NOP 				 8'b1100_0000
`define CPU_INSTR_HLT 				 8'b1100_0001
`define CPU_INSTR_INC_AR 			 8'b1100_0010

/*


*/
