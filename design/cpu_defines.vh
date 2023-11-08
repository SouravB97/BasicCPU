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
`define CB_MID_RANGE						7:5  
`define CB_SID_RANGE					 10:8  
`define CB_ALU_OPCODE_RANGE		 15:11  
`define CB_HLT_RANGE	 				 16:16  
`define CB_CLR_TIMER_RANGE	 	 17:17  
`define CB_AR_INR_RANGE	 	 		 18:18  
`define CB_ALU_EN_RANGE	 	 		 19:19  

`define DEC_OP(op) \ //gives same output as ir0_decoder
	(op >> `OPCODEWORD_DECODE_OFFSET)	& {`OPCODEWORD_ALU_OPCODE_WIDTH{1'b1}}
`define IS_MOV(op) (op >> `OPCODEWORD_TYPE_OFFSET) ^ 2'b00
`define IS_MVI(op) (op >> `OPCODEWORD_TYPE_OFFSET) ^ 2'b01
`define IS_ALU(op) (op >> `OPCODEWORD_TYPE_OFFSET) ^ 2'b10
`define IS_SYS(op) ((op >> `OPCODEWORD_TYPE_OFFSET) ^ 2'b11) & ((op >> `OPCODEWORD_CMP_OFFSET) | 1'b0)
`define IS_CMP(op) ((op >> `OPCODEWORD_TYPE_OFFSET) ^ 2'b11) & ((op >> `OPCODEWORD_CMP_OFFSET) & 1'b1)

`define OPCODEWORD_TYPE_RANGE						7:6
`define OPCODEWORD_CMP_RANGE						5:5
`define OPCODEWORD_ALU_OPCODE_RANGE			4:0
`define OPCODEWORD_DECODE_RANGE					`OPCODEWORD_ALU_OPCODE_RANGE
`define OPCODEWORD_SID_RANGE						5:3
`define OPCODEWORD_MID_RANGE						2:0
`define OPCODEWORD_ALU_STATUS_RANGE			1:0
`define OPCODEWORD_FLIPCMP_RANGE				2:2

`define OPCODEWORD_TYPE_OFFSET					6
`define OPCODEWORD_CMP_OFFSET						5
`define OPCODEWORD_ALU_OPCODE_OFFSET		0
`define OPCODEWORD_DECODE_OFFSET				`OPCODEWORD_ALU_OPCODE_OFFSET

`define OPCODEWORD_ALU_OPCODE_WIDTH 		5
`define OPCODEWORD_MID_WIDTH						3
`define OPCODEWORD_SID_WIDTH						3

