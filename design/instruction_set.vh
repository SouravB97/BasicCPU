//MVI instruction
`define CPU_INSTR_LDA 				 8'b0101_0001	//0x11
`define CPU_INSTR_LDB 				 8'b0101_1001	//0x19
`define CPU_INSTR_LDAR0 			 8'b0110_0001	//0x21
`define CPU_INSTR_LDAR1 			 8'b0110_1001	//0x29
`define CPU_INSTR_LDPC0 			 8'b0111_0001	//0x31
`define CPU_INSTR_LDPC1 			 8'b0111_1001	//0x39

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

//unconditional branch, same as LD_PC0
`define CPU_INSTR_JMP			 			 8'b0111_0001	//0x31
`define CPU_INSTR_BUN			 			 8'b0111_0001	//0x31


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
|10xxx	|'h10-'h17		 |RSH		|C = A >> 1;		|Shift right         |
|11xxx	|'h18-'h1F		 |LSH		|C = A << 1;		|Shift left          |
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
`define CPU_INSTR_RSH 				 8'b1001_0000
`define CPU_INSTR_LSH 				 8'b1001_1000

//SYSTEM instructions
`define CPU_INSTR_NOP 				 8'b1100_0000
`define CPU_INSTR_HLT 				 8'b1100_0001
`define CPU_INSTR_INC_AR 			 8'b1100_0010

//Conditional Jumps
`define CPU_INSTR_JCAR				 8'b1110_0000
`define CPU_INSTR_JNCAR				 8'b1110_0100
`define CPU_INSTR_JEPAR				 8'b1110_0001
`define CPU_INSTR_JOPAR				 8'b1110_0101
`define CPU_INSTR_JZER				 8'b1110_0010
`define CPU_INSTR_JNZER				 8'b1110_0110
`define CPU_INSTR_JNEG				 8'b1110_0011
`define CPU_INSTR_JPOS				 8'b1110_0111

//CISC INSTRUCTIONS
`define CISC_INSTR_	0

/*

$VAR1 = {
          'LDA' => '51',
          'MOV_PC0_A' => '16',
          'LDPC0' => '71',
          'MOV_MEM_AR1' => '29',
          'MOV_AR1_PC1' => '3d',
          'MOV_MEM_B' => '19',
          'MOV_MEM_AR0' => '21',
          'MOV_AR1_PC0' => '35',
          'MOV_A_PC0' => '32',
          'MOV_PC1_AR1' => '2f',
          'MOV_B_AR1' => '2b',
          'SAR0' => 'c',
          'MOV_AR1_MEM' => 'd',
          'MOV_PC1_AR0' => '27',
          'MOV_PC1_B' => '1f',
          'SAR1' => 'd',
          'MOV_A_B' => '1a',
          'ADD' => '82',
          'JMP' => '71',
          'MOV_A_MEM' => 'a',
          'LDPC1' => '79',
          'SUB' => '85',
          'MOV_B_A' => '13',
          'SPC0' => 'e',
          'RSH' => '90',
          'JZER' => 'e2',
          'JOPAR' => 'e5',
          'SPC1' => 'f',
          'NOP' => 'c0',
          'LSH' => '98',
          'MOV_B_AR0' => '23',
          'MOV_A_PC1' => '3a',
          'INC_AR' => 'c2',
          'AND' => '88',
          'MOV_AR1_A' => '15',
          'MOV_PC0_PC1' => '3e',
          'LDB' => '59',
          'MOV_AR0_B' => '1c',
          'HLT' => 'c1',
          'DEC' => '86',
          'MOV_AR0_AR1' => '2c',
          'BUN' => '71',
          'JNEG' => 'e3',
          'MOV_PC0_MEM' => 'e',
          'CMP' => '8e',
          'MOV_MEM_PC1' => '39',
          'STA' => 'a',
          'MOV_PC1_MEM' => 'f',
          'MOV_AR1_AR0' => '25',
          'MOV_AR1_B' => '1d',
          'MOV_MEM_PC0' => '31',
          'JEPAR' => 'e1',
          'JNZER' => 'e6',
          'LD1' => '87',
          'MOV_AR0_A' => '14',
          'JNCAR' => 'e4',
          'MOV_A_AR0' => '22',
          'MOV_B_PC1' => '3b',
          'OR' => '8a',
          'LD' => '80',
          'MOV_PC1_PC0' => '37',
          'MOV_PC0_AR0' => '26',
          'MOV_PC0_B' => '1e',
          'MOV_B_PC0' => '33',
          'MOV_A_AR1' => '2a',
          'XOR' => '8c',
          'ADC' => '83',
          'JPOS' => 'e7',
          'MOV_PC0_AR1' => '2e',
          'MOV_MEM_A' => '11',
          'LDAR1' => '69',
          'SBB' => '84',
          'INC' => '81',
          'MOV_AR0_MEM' => 'c',
          'MOV_B_MEM' => 'b',
          'LDAR0' => '61',
          'STB' => 'b',
          'MOV_AR0_PC0' => '34',
          'JCAR' => 'e0',
          'MOV_PC1_A' => '17',
          'MOV_AR0_PC1' => '3c'
        };
Total instructions: 81
*/
