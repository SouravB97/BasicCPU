#!/usr/bin/perl 
use strict;
use warnings;

use List::Util qw(first);
use Data::Dumper;

my %control_word_map = (
	#MID, SID, AMID,
	'alu_opcode' => 33, 
	'OE_AR' 		 => 32,
	'OE_PC' 		 => 31, 
	'OE_SP' 		 => 30,
	'OE_R0R1' 	 => 29,
	'OE_SR' 		 => 28,
	'OE_ALU' 		 => 27,
	'PC_INR'		 => 26,
	'OE_A'			 => 25,
	'OE_B'			 => 24,
	'OE_R0'			 => 23,
	'OE_R1'			 => 22,
	'OE_IR0'		 => 21,
	'OE_IR1'		 => 20,
	'OE_AR0'		 => 19,
	'OE_AR1'		 => 18,
	'OE_PC0'		 => 17,
	'OE_PC1'		 => 16,
	'OE_SP0'		 => 15,
	'OE_SP1'		 => 14,
	'OE_M' 			 => 13,
	'WE_A' 			 => 12,
	'WE_B' 			 => 11,
	'WE_R0'			 => 10,
	'WE_R1'			 => 9,
	'WE_IR0'		 => 8,
	'WE_IR1'		 => 07,
	'WE_AR0'		 => 06,
	'WE_AR1'		 => 05,
	'WE_PC0'		 => 04,
	'WE_PC1'		 => 03,
	'WE_SP0'		 => 02,
	'WE_SP1'		 => 01,
	'WE_M'			 => 00
);

my $output_file = "/c/Users/soura/Documents/Verilog/testing/scripts/micro_code.hex";
`rm -f $output_file`;

#Instructions
#Specify all the signals that should be 1 at that clock cycle/T state

#fetch
my @fetch = (
	[['OE_PC', 1],  ['OE_M', 1]],
  [['OE_PC', 1],  ['OE_M', 1], ['WE_IR0',1], ['PC_INR', 1]],
  [['OE_PC', 1],  ['OE_M', 1], ['WE_IR0',0], ['PC_INR', 0]],
  [['OE_PC', 1],  ['OE_M', 1], ['WE_IR1',1], ['PC_INR', 1]]
#	[['OE_PC', 0],  ['OE_M', 0], ['WE_IR1',0], ['PC_INR', 0]],
);
 
print Dumper(\@fetch);
gen_microcode(\@fetch, 0x00); #instuction array, relative offset

#MOV microcodes
#MOV offset = 'h4, microcode line number 4
#SRC = 15, DST = 13, SRC.DST = 195 unique microcodes

#			case(SRC)
#				0:	assign OE_IR0 = OE;
#				1:	assign OE_IR1 = OE;
#				2:	assign OE_A = OE;
#				3:	assign OE_B = OE;
#				4:	assign OE_M = OE;
#				5:	assign OE_R0 = OE;
#				6:	assign OE_R1 = OE;
#				7:	assign OE_AR0 = OE;
#				8:	assign OE_AR1 = OE;
#				9:	assign OE_PC0 = OE;
#				10:	assign OE_PC1 = OE;
#				11:	assign OE_SP0 = OE;
#				12:	assign OE_SP1 = OE;
#				13: assign OE_SR  = OE;
#				14: assign OE_ALU  = OE;
#			endcase
#
#			case(DST)
#				0:	assign WE_IR0 = WE;
#				1:	assign WE_IR1 = WE;
#				2:	assign WE_A = WE;
#				3:	assign WE_B = WE;
#				4:	assign WE_M = WE;
#				5:	assign WE_R0 = WE;
#				6:	assign WE_R1 = WE;
#				7:	assign WE_AR0 = WE;
#				8:	assign WE_AR1 = WE;
#				9:	assign WE_PC0 = WE;
#				10:	assign WE_PC1 = WE;
#				11:	assign WE_SP0 = WE;
#				12:	assign WE_SP1 = WE;
#			endcase

#We just need to generate instruction array and let it run

my @mov_routines;

my @SRC = ('OE_IR0', 'OE_IR1', 'OE_A', 'OE_B', 'OE_M', 'OE_R0', 'OE_R1','OE_AR0', 'OE_AR1', 'OE_PC0', 'OE_PC1', 'OE_SP0', 'OE_SP1', 'OE_SR', 'OE_ALU');
my @DST = ('WE_IR0', 'WE_IR1', 'WE_A', 'WE_B', 'WE_M', 'WE_R0', 'WE_R1','WE_AR0', 'WE_AR1', 'WE_PC0', 'WE_PC1', 'WE_SP0', 'WE_SP1');

foreach my $src (@SRC){
	foreach my $dst (@DST){
		#print "$i: $src, $dst\n";

		#@{@{$mov_routines[$i]}[0]}[0] = $src;
		#@{@{$mov_routines[$i]}[0]}[1] = 1;
		#@{@{$mov_routines[$i]}[1]}[0] = $dst;
		#@{@{$mov_routines[$i]}[1]}[1] = 1;

		push @mov_routines, [[$src, 1],  [$dst, 1]];

	}
}

#push @mov_routines, (['WE_IR0', 1],  ['OE_IR1', 1]);
#@{@{$mov_routines[1]}[0]}[0] = 'WE_A';
#@{@{$mov_routines[1]}[0]}[1] = '0';

print Dumper(\@mov_routines);
gen_microcode(\@mov_routines, 0x00); #instuction array, relative offset


print("\n\nContents of $output_file :\n\n");
system("cat $output_file");
1;


#===============================================================================================================================================
#INPUTS:
#@instruction: Instruction data structure
#$offset: relative offset from last instruction
sub gen_microcode{

	my @instruction = @{$_[0]};
	my $offset = $_[1];

	open(OUT, '>>', $output_file) or die $!; #append for now TODO

	#TODO
	#seek to relative offset and PAD with 0s
	for(my $i = 0; $i < $offset; $i = $i+1){
		my $control_word_hex = sprintf("%016x", 0x00);
		print OUT "$control_word_hex\n"
	}

	#my $control_word = 0x00;
	foreach my $code_line (@instruction){
		my $control_word = 0x00;

		#Each code word is applied to control bus once in each Timing cycle
		foreach my $code_word (@$code_line){
				my $bit_name = $code_word->[0];
				my $value = $code_word->[1];

				my $bit_pos = $control_word_map{$bit_name};
				print "$bit_name, $bit_pos, $value\t";

				if($value){
					$control_word = $control_word | (1 << $bit_pos);
				}
				else{
					$control_word = $control_word & ~(1 << $bit_pos);
				}

		}

		#my $control_word_bin = sprintf("'B%B", $control_word);
		#print "\t$control_word_bin\n";
		print "\n";
		
		my $control_word_hex = sprintf("%016x", $control_word);
		print OUT "$control_word_hex\n"
	}

	close OUT;

}
