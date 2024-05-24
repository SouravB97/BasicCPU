# Basic CPU
This is a basic 8bit CPU with 2 Registers(A and B), an ALU, Programme counter, Address register, Instruction register, 256 bytes of Memory and a Timing and Control unit.
A register and ALU constitute the Accumulator.
The data bus is 8bit wide, the Address bus is 16 bits and the instruction opcodes are also 8 bits.
There is no pipelining. Most instructions take 2 cycles to perform, Fetch at T0 and decode + Execute at T1.

There is no behavioural modelling anywhere in the design, besides the memory model in ($STEM/design/BHVR/memory_bhvr.v)
All the CPU logic is built bottom-up using logic gates.
Logic gates -> Digital components (Flops, Muxes, Decoders) -> More complex components (ALU, Registers) -> CPU
The Timing and control unit uses hard-wired control logic. The instruction opcodes are decoded using decoders, and the corresponding outputs are driven by simple logic operations.
This way, this design is closer to a synthesized netlist, that can be implemented on a breadboard than HDL code.

# How to get started:
1. source bootenv; #Basic environment configuration
3. cd testbench; ./rerun_command; #Fires the testbench, shows the output and opens the waveform viewer

# How to run a custom programme:
Simplest way:
1. Write the assemble code in $STEM/asm_programmes/bootcode.asm and run using $STEM/testbench/rerun_command
Run other code:
1. Create a new file, Ex: $STEM/asm_programmes/fibonacci_save.asm
2. Make changes in rerun command to assemble fibonacci_save.asm instead of bootcode.asm 
3. Make changes in TB_TOP to pass new object file, and run using rerun_command.
Script to run other code: Leaves TB files unchanged and dumps new output files based on asm file name
1. cd testbench ;
2. $STEM/scripts/run_asm $STEM/asm_programmes/fibonacci_save.asm

# The Simulation:
1. The script clears all previous output files.
2. Then it assembles the code at $STEM/asm_programmes/bootcode.asm into $STEM/asm_programmes/compiled_hex/bootcode.hex. It invokes the perl assembler at $STEM/scripts/assembler.pl
3. Runs the testbench $STEM/testbench/CPU_tb.v
4. This loads bootcode.hex into memory and instantiates the DUT from $STEM/design/CPU.v
5. Starts the CPU by releasing the reset signal and starting clk.
6. The CPU executes the code in memory and dumps the output back into memory.
7. The testbench dumps the memory contents into $STEM/dump/output.hex where it can be viewed.
8. It also dumps the waveforms into $STEM/dump/CPU_tb.vcd 
9. The rerun command scripts loads the waveforms into gtkwave

# Testbench Architechture:
The TB_TOP is present in $STEM/testbench/CPU_tb.v file. It instantiates the DUT located at $STEM/design/CPU.v
The CPU executes $STEM/asm_programmes/bootcode.asm and dumps the memory contents to $STEM/dump/output.hex at the end of sim.
The waves are loaded from $STEM/dump/CPU_tb.vcd
The TB monitors the running CPU, and exits the sim once HLT is detected, or if something goes wrong and the CPU runs indefinitely, it waits for a certian max cycles and then kills the sim.


# Assembler
The perl assembler supports standard assembly syntax.
It gets the list of opcodes and their corresponding value from $STEM/design/instruction_set.vh
It parses the asm file (<filename>.asm) multiple times and generates the object file at $STEM/asm_programmes/compiled_hex/<filename>.hex
This assembler supports preprocessor directives, as well as . So it can be used to assemble more complex programes, like ($STEM/asm_programmes/fibonacci_save.asm)
It supports the following assembler directives and C style macros:
#define, #orig, #db
It supports labels, which can be used in jump instructions:
Ex:
	loop: lsh
		jncar loop
	hlt
It is case insensitive, and white space insensitive. Commands are terminated by new line, so no semicolon needed.
comments are added by ;;
It supports all number formats: 17, 17D, 17d, 0x11, 0X11, 11H, 11h, 0b10001, 0B10001 all mean the same thing. (Thanks regex)

The assembler works by doing the following steps:
1.  Load the opcodes into internal hash
2.  Load the preprocessor directives
3.  Load CISC instructions, which are just a combination of RISC instructions to be executed in serial. This simplifies assembly programming.
4.  Checks for syntax error. Throws error with line number if found.
5.  Once syntax is clean, it starts parsing.
6.  Removes comments and white spaces
7.  Calls preprocessor. Does preprocessor substitutions, like #defines.
8.  Removes new lines.
9.  Reads labels and notes down its memory location
10. Executes assembler directives like .ORIG
11. Substitutes opcodes and opcode arguements
12. Print the final result into the output hex file. If -randomize is selected, it pads the empty memory locations with random values. Else it pads with ff.

# How to add new opcodes:
Add the instruction into instruction.hex (See $STEM/design/instruction_set.vh) . Follow the rules so that decoding becomes easier:
opcode[7:6] = {
		00 :	Move instruction 
		01 :	Move Immediate Instruction
		10 :  ALU invoke Instruction
		11 :  Other System Instruction
}
For Move Instruction:
opcode[2:0] = Master ID (MID), the ID of the CPU component from which to read.
opcode[5:3] = Slave ID (SID), the ID of the CPU component to be written.

For ALU instruction:
opcode[4:0] = ALU opcode, directly fed to ALU opcode bus. (See $STEM/design/ALU.v)

Add the corresponding logic in the CPU, using decoders and logic gates, and maybe muxes.

