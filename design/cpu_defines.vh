/*
Address map:

RAM: 0x0000-0x00FF
IO:  0x8000-0x8004
*/
	/*
		SID	|	Register
		0	|	IR0	
		1	|	IR1
		2	|	A
		3	|	B
		4	|	Mem
		5	|	R0
		6	|       R1
		7	|       AR0
		8	|	AR1
		9	|	PC0
		10	|	PC1
		11	|	SP0
		12	|	SP1
		13	|	PORTA
		14	|	PORTB
		15	|	PORTC
		16	|	PORTD

		MID	|	Register
		0	|	IR0	
		1	|	IR1
		2	|	A
		3	|	B
		4	|	Mem
		5	|	R0
		6	|       R1
		7	|       AR0
		8	|	AR1
		9	|	PC0
		10	|	PC1
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
`define CPU_INSTR_LDA 				 8'b0001_0100	//0x14
`define CPU_INSTR_LDB 				 8'b0001_1100	//0x1C

//ALU instructions
`define CPU_INSTR_ADD 				 8'b0100_0111	//0x47

//SYSTEM instructions
`define CPU_INSTR_NOP 				 8'b1000_0000	//0x80
`define CPU_INSTR_HLT 				 8'b1000_0001	//0x81
