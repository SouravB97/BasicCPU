# Basic CPU
This is a basic 8-bit CPU with 2 Registers(A and B), an ALU, a Programme counter, an Address register, an Instruction register, 256 bytes of Memory and a Timing and Control unit.
A register and ALU constitute the Accumulator.
The data bus is 8 bits wide, the Address bus is 16 bits wide of which the lower 8 are in use. The instruction opcodes are also 8 bits.
There is no pipelining. Instructions take 3 or 4 cycles to perform; instruction fetch at T0, T1 followed by decode and execute at T2. If a memory read needs to happen it can stretch up to T3.
Memory read takes 2 cycles, Memory write needs 1, and Register read takes 1.
Opcode fetch consumes 2 cycles as it is a memory read.

There is no behavioural modelling anywhere in the design, besides the memory model in ($STEM/design/BHVR/memory_bhvr.v)
All the CPU logic is built bottom-up using logic gates.
Logic gates -> Digital components (Flops, Muxes, Decoders) -> More complex components (ALU, Registers) -> CPU
The Timing and control unit uses hard-wired control logic. The instruction opcodes are decoded using decoders, and the corresponding outputs are driven by simple logic operations.
This way, this design is closer to a synthesized netlist, that can be implemented on a breadboard than HDL code.

# CPU Block Diagram:
TODO

# How to get started:
1. source bootenv; #Basic environment configuration
3. cd testbench; #TB exists here 
4. $STEM/scripts/run_asm $STEM/asm_programmes/bootcode.hex # Script simulates the TB, loads bootcode onto the CPU and lets it execute.

# How to run a custom programme:
Simplest way:
1. Write the assembly code in $STEM/asm_programmes/bootcode.asm and run using $STEM/testbench/rerun_command
Run other code:
1. Create a new file, Ex: $STEM/asm_programmes/fibonacci_save.asm
2. Make changes in the rerun command to assemble fibonacci_save.asm instead of bootcode.asm 
3. Make changes in TB_TOP to pass new object file, and run using rerun_command.
Script to run other code: Leaves TB files unchanged and dumps new output files based on asm file name
1. cd testbench ;
2. $STEM/scripts/run_asm $STEM/asm_programmes/fibonacci_save.asm

# How to run any Verilog code:
It uses the Icarus Verilog simulator, and gtkwave waveform viewer.
The commands to run any design using these are encapsulated in $STEM/scripts/irun.bat, which is aliased to 'irun'
1. irun CPU_tb.v #compiles and simulates design

# The Simulation:
1. The script clears all previous output files.
2. Then it assembles the code at $STEM/asm_programmes/bootcode.asm into $STEM/asm_programmes/compiled_hex/bootcode.hex. It invokes the perl assembler at $STEM/scripts/assembler.pl
3. Runs the testbench $STEM/testbench/CPU_tb.v
4. This loads bootcode.hex into memory and instantiates the DUT from $STEM/design/CPU.v
5. Starts the CPU by releasing the reset signal and starting clk.
6. The CPU executes the code in memory and dumps the output back into memory.
7. The testbench dumps the memory contents into $STEM/dump/output.hex where it can be viewed.
8. It also dumps the waveforms into $STEM/dump/bootcode.vcd and loads it into the gtkwave waveform viewer.

# Testbench Architechture:
The TB_TOP is present in $STEM/testbench/CPU_tb.v file. It instantiates the DUT located at $STEM/design/CPU.v
The CPU executes $STEM/asm_programmes/bootcode.asm and dumps the memory contents to $STEM/dump/bootcode.hex at the end of the sim.
The waves are loaded from $STEM/dump/bootcode.vcd
The TB monitors the running CPU and exits the sim once HLT is detected, or if something goes wrong and the CPU runs indefinitely, it waits for a certain max cycle and then kills the sim.


# Assembler
The perl assembler supports standard assembly syntax.
It gets the list of opcodes and their corresponding value from $STEM/design/instruction_set.vh
It parses the asm file (<filename>.asm) multiple times and generates the object file at $STEM/asm_programmes/compiled_hex/<filename>.hex
This assembler supports preprocessor directives, as well as. So it can be used to assemble more complex programmes, like ($STEM/asm_programmes/fibonacci_save.asm)
It supports the following assembler directives and C-style macros:
#define, #orig, #db
It supports labels, which can be used in jump instructions:
Ex:
	loop: lsh
		jncar loop
	hlt
It is case-insensitive, and white space-insensitive. Commands are terminated by a new line, so no semicolon is needed.
comments are added by ;;
It supports all number formats: 17, 17D, 17d, 0x11, 0X11, 11H, 11h, 0b10001, 0B10001 all mean the same thing. (Thanks regex)

The assembler works by doing the following steps:
1.  Load the opcodes into the internal hash
2.  Load the preprocessor directives
3.  Load CISC instructions, just a combination of RISC instructions to be executed in serial. This simplifies assembly programming.
4.  Checks for syntax errors. Throws error with line number if found.
5.  Once syntax is clean, it starts parsing.
6.  Removes comments and white spaces
7.  Calls preprocessor. Does preprocessor substitutions, like #defines.
8.  Removes new lines.
9.  Reads labels and notes down its memory location
10. Executes assembler directives like .ORIG
11. Substitutes opcodes and opcode arguments
12. Print the final result into the output hex file. If -randomize is selected, it pads the empty memory locations with random values. Else it pads with ff.

# Anatomy of instruction word (opcode)
The opcode is always 8 bits wide. The value of the opcode is not picked at random, rather it has the following fields which are decoded by the CPU.

There are 5 types of instructions this CPU supports:
	1 MOV			#Move: Instructions involving moving data around.
	2 MVI			#MVI: Move immediate. Instructions involving loading the given arguement directly into CPU reg
	3 ALU			#Arithmatic/Logical operations
	4 SYSTEM	#System instructions like HLT, NOP
	5 CJMP		#Conditional jump


7:6 opcode type
	0 MOV			#Move: Instructions involving moving data around.
	1 MVI			#MVI: Move immediate. Instructions involving loading the given arguement directly into CPU reg
	2 ALU			#Arithmatic/Logical operations
	3 OTHERS	#System instructions like HLT, NOP

For MOV and MVI:
	5:3 SID (slave ID)	component which gets written. see table for SID decoder
	2:0 MID (Master ID) component which gets read. see table for MID decoder

For ALU instructions:
	4:0 ALU opcode. To be passed to ALU. see ALU table

For OTHER instructions:
	5:5 Compare range
		0 SYSTEM instruction
		1 Conditional Jump

# RTL Table
![image](https://github.com/SouravB97/BasicCPU/assets/42449435/e6ed579b-7260-4a7a-b3d4-cfc239dab10a)

# How to add new opcodes:
Add the instruction into the instruction.hex (See $STEM/design/instruction_set.vh) . Follow the rules so that decoding becomes easier:

Add the corresponding logic in the CPU, using decoders and logic gates, and maybe muxes.

# **Timing Diagrams:**
1. Opcode fetch: This is a memory read from the PC0 address. All instructions need to fetch the opcode. It takes 2 cycles.
   ![image](https://github.com/SouravB97/BasicCPU/assets/42449435/b68399ad-5059-436a-86d7-ca7e077eb8d0)
2. Move register - register: After opcode fetch, this instruction takes one cycle to execute.
   ![image](https://github.com/SouravB97/BasicCPU/assets/42449435/3c9b9de9-febe-4af3-ab0b-3b8754b23566)
   ![image](https://github.com/SouravB97/BasicCPU/assets/42449435/0308249a-5be1-4ce9-bd4a-3179d7c8f01f)
3. Move Immediate: This instruction loads memory data at the address (PC+1) location into a register. Since it has 2 memory reads, it needs 4 cycles to execute. It is useful for initialising registers with hardcoded values. 
   ![image](https://github.com/SouravB97/BasicCPU/assets/42449435/7d05be91-e467-466d-82dc-9ee538e06557)
4. Memory read: This instruction loads memory data at the AR0 address into a register. It is useful for loading variable values into the CPU registers, by loading pointer adderss into AR0.
    ![image](https://github.com/SouravB97/BasicCPU/assets/42449435/ee0d4c10-66b3-4da1-89a9-6b6bd1aa4bfd)
5. ALU operation: ALU takes input from A and sometimes B registers and stores the results back into A. Instruction takes 3 cycles.
   ![image](https://github.com/SouravB97/BasicCPU/assets/42449435/f6bc4288-461c-42b9-8425-1fe5db27997e)
6. Unconditional Jump/Branch: Load the immediate address into the PC0 register. It involves a memory read so takes 4 cycles.
   ![image](https://github.com/SouravB97/BasicCPU/assets/42449435/6a6e4628-edf7-4bda-b6c2-8043ba1b4dec)
7. Conditional Jump: Perform a jump based on ALU status. It can take 3 or 4 cycles.
   ![image](https://github.com/SouravB97/BasicCPU/assets/42449435/6c975003-1831-4a7b-8eef-e919163d29d2)
   ![image](https://github.com/SouravB97/BasicCPU/assets/42449435/4a44214e-0a83-4678-9cfc-9904e062eb8c)

# Waveform Screenshots:
Here's a waveform dump from the fibonacci programme:
How to run:
1. source bootenv ;
2. cd testbench;
3. $STEM/scripts/run_asm $STEM/asm_programmes/fibonacci.asm

Code:
	#define origin 20h
	#define a efh
	
	jmp `origin
	
	#orig `origin
	ldar0 `a
	lda 1
	ldb 0
	loop: mov_a_mem
		add
		mov_mem_b
		jncar loop
	hlt

Output Dump:
![Screenshot 2024-07-06 124414](https://github.com/SouravB97/BasicCPU/assets/42449435/d73609de-1b1f-4d83-bee7-af8a9c520b72)




