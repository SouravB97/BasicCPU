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
`define CB_ALU_OPCODE_RANGE		 15:13  
`define CB_HLT_RANGE	 				 16:16  
`define CB_CLR_TIMER_RANGE	 	 17:17  

`define DEC_OP(op) \ //gives same output as ir0_decoder
	(op >> `OPCODEWORD_DECODE_OFFSET)	& {`OPCODEWORD_ALU_OPCODE_WIDTH{1'b1}}
`define IS_MVI(op) (op >> `OPCODEWORD_TYPE_OFFSET) ^ 2'b00
`define IS_ALU(op) (op >> `OPCODEWORD_TYPE_OFFSET) ^ 2'b01
`define IS_SYS(op) (op >> `OPCODEWORD_TYPE_OFFSET) ^ 2'b10

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
//memory_load
`define CPU_INSTR_LDA 				 8'b0001_0001	//0x11
`define CPU_INSTR_LDB 				 8'b0001_1001	//0x19
`define CPU_INSTR_LAR0 				 8'b0010_0001	//0x21
`define CPU_INSTR_LAR1 				 8'b0010_1001	//0x29
`define CPU_INSTR_LPC0 				 8'b0011_0001	//0x31
`define CPU_INSTR_LPC1 				 8'b0011_1001	//0x39
`define CPU_INSTR_STA 				 8'b0000_1010	//0x0A
`define CPU_INSTR_STB 				 8'b0000_1011	//0x0B
`define CPU_INSTR_SAR0 				 8'b0000_1100	//0x0C
`define CPU_INSTR_SAR1 				 8'b0000_1101	//0x0D
`define CPU_INSTR_SPC0 				 8'b0000_1110	//0x0E
`define CPU_INSTR_SPC1 				 8'b0000_1111	//0x0F

//ALU instructions
`define CPU_INSTR_ADD 				 8'b0100_0111	//0x47

//SYSTEM instructions
`define CPU_INSTR_NOP 				 8'b1000_0000	//0x80
`define CPU_INSTR_HLT 				 8'b1000_0001	//0x81
