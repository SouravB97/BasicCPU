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
`define CB_ALU_OPCODE_RANGE		 16:13  
`define CB_HLT_RANGE	 				 17:17  
`define CB_CLR_TIMER_RANGE	 	 18:18  

`define OPCODEWORD_OPCODE_RANGE		2:0


