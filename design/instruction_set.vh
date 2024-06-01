//MOV instruction
//{2'op_type, 3'sid, 3'mid}
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

//MVI instruction
//{2'op_type, 3'sid, 3'mem_mid}
//`define CPU_INSTR_LDMEM 			 8'b0100_1001	//0x11
`define CPU_INSTR_LDA 				 8'b0101_0001	//0x11
`define CPU_INSTR_LDB 				 8'b0101_1001	//0x19
`define CPU_INSTR_LDAR0 			 8'b0110_0001	//0x21
`define CPU_INSTR_LDAR1 			 8'b0110_1001	//0x29
`define CPU_INSTR_LDPC0 			 8'b0111_0001	//0x31
`define CPU_INSTR_LDPC1 			 8'b0111_1001	//0x39

//unconditional branch, same as LDPC0
//Only valid for 8 bits. Need to add CISC instruction for 16 bits.
//JMP = LDPC0 addr_low ; LDPC1 addr_hi
`define CPU_INSTR_JMP			 			 8'b0111_0001	//0x31
`define CPU_INSTR_BUN			 			 8'b0111_0001	//0x31


//ALU instructions
//{2'op_type, 1'unused, 5'alu_opcode}
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
//{2'op_type, 1'cj_range, 4'unused, 2'system_inst}
`define CPU_INSTR_NOP 				 8'b1100_0000
`define CPU_INSTR_HLT 				 8'b1100_0001
`define CPU_INSTR_INC_AR 			 8'b1100_0010

//Conditional Jumps
//{2'op_type, 1'cj_range, 2'unused, 1'flip_cmp, 2'compare_criteria}
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
Generate from $STEM/scripts/assembler.pl -show
$VAR1 = {
          'MOV_PC0_AR0' => '26',
          'XOR' => '8c',
          'MOV_AR0_AR1' => '2c',
          'MOV_B_AR0' => '23',
          'RSH' => '90',
          'MOV_AR1_MEM' => 'd',
          'MOV_B_PC0' => '33',
          'LDPC0' => '71',
          'JNEG' => 'e3',
          'MOV_MEM_PC0' => '31',
          'MOV_AR0_B' => '1c',
          'MOV_B_A' => '13',
          'MOV_PC1_A' => '17',
          'MOV_AR1_PC1' => '3d',
          'MOV_MEM_A' => '11',
          'MOV_B_PC1' => '3b',
          'JMP' => '71',
          'MOV_PC1_PC0' => '37',
          'MOV_A_MEM' => 'a',
          'JZER' => 'e2',
          'SUB' => '85',
          'INC' => '81',
          'AND' => '88',
          'MOV_B_AR1' => '2b',
          'LDB' => '59',
          'SBB' => '84',
          'DEC' => '86',
          'LD1' => '87',
          'MOV_AR1_PC0' => '35',
          'OR' => '8a',
          'LDPC1' => '79',
          'MOV_PC1_MEM' => 'f',
          'JNZER' => 'e6',
          'MOV_A_B' => '1a',
          'MOV_PC0_B' => '1e',
          'MOV_AR1_A' => '15',
          'MOV_MEM_PC1' => '39',
          'MOV_PC0_AR1' => '2e',
          'JNCAR' => 'e4',
          'CMP' => '8e',
          'BUN' => '71',
          'MOV_A_AR1' => '2a',
          'LD' => '80',
          'MOV_B_MEM' => 'b',
          'MOV_AR0_PC0' => '34',
          'MOV_MEM_B' => '19',
          'MOV_PC0_PC1' => '3e',
          'MOV_A_PC1' => '3a',
          'NOP' => 'c0',
          'MOV_MEM_AR1' => '29',
          'MOV_PC1_AR1' => '2f',
          'JCAR' => 'e0',
          'MOV_AR1_AR0' => '25',
          'LDAR0' => '61',
          'MOV_A_PC0' => '32',
          'MOV_PC0_MEM' => 'e',
          'MOV_AR0_A' => '14',
          'ADC' => '83',
          'MOV_A_AR0' => '22',
          'MOV_PC1_B' => '1f',
          'MOV_AR0_MEM' => 'c',
          'LSH' => '98',
          'MOV_PC0_A' => '16',
          'LDA' => '51',
          'MOV_AR1_B' => '1d',
          'LDAR1' => '69',
          'HLT' => 'c1',
          'MOV_PC1_AR0' => '27',
          'INC_AR' => 'c2',
          'JOPAR' => 'e5',
          'MOV_MEM_AR0' => '21',
          'ADD' => '82',
          'JEPAR' => 'e1',
          'JPOS' => 'e7',
          'MOV_AR0_PC1' => '3c'
        };
Total instructions: 75

*/
