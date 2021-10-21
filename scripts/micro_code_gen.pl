#!/usr/bin/perl 
use List::Util qw(first);
use strict;
use warnings;

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

my $output_file = "micro_code.hex";

#Instructions

#fetch
my @instruction = (
	[['OE_PC', 1],  ['OE_M', 1]],
  [['WE_IR0',1], ['PC_INR', 1]],
  [['WE_IR0',0], ['PC_INR', 0]],
  [['WE_IR1',1], ['PC_INR', 1]],
	[['OE_PC', 0],  ['OE_M', 0], ['WE_IR1',0], ['PC_INR', 0]],
);
 
open(OUT, '>', $output_file) or die $!;

my $control_word = 0x00;
foreach my $code_line (@instruction){

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
	my $control_word_bin = sprintf("'B%B", $control_word);
	my $control_word_hex = sprintf("%08x", $control_word);
	print "\t$control_word_bin\n";
	print OUT "$control_word_hex\n"
}

close OUT;
print("\n\nContents of $output_file :\n\n");
system("cat $output_file");
