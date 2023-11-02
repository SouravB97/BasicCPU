#!/usr/bin/perl 
use strict;
use warnings;

use List::Util qw(first);
use Data::Dumper;
use Getopt::Long;

my $defines_file = "$ENV{STEM}/design/cpu_defines.vh";
my $input_file = "$ENV{STEM}/testbench/bootcode_1.asm";
my $output_file = $input_file;
my %ins_map;
my $code_byte_size = 0;
my $memory_depth = 256;
my $memory_width = 1;	#in bytes
my $max_val = 2**($memory_width*8)-1;
my @mem = ($max_val) x $memory_depth;
my $mem_ptr = 0;
my $delete_tmp = 1;
my $randomize;
my $help;
my $help_message = 
"	Help Message	\
	source bootenv to setup ENV vars.
"
;
#printf ("@mem\nsize mem: %d\n", scalar @mem);

$output_file =~ s/.asm/.hex/g;
$output_file =~ s/testbench/testbench\/micro_codes/g;

GetOptions ( 
"f|inp=s" => \$input_file,
"out=s" => 	\$output_file,
"h|help" => 	\$help,
"mem_depth=s" => 	\$memory_depth,
"rand|randomize" => 	\$randomize
);

if(defined $help){
	print "$help_message";
	exit();
}

print "input file: $input_file\n" ;
print "Output file: $output_file\n" ;

`cp $input_file $input_file.tmp`;
$input_file = $input_file.".tmp";

open(DATA, "<$defines_file") or die "Couldn't open file $defines_file, $!";

while(my $line = <DATA>) {
	if($line =~ /CPU_INSTR_(\w+)\s+(\S+)/){
		my $ins_word = $1;
		my $opcode = $2;
		$opcode =~ s/_//;
		if($opcode =~ /'b([01]*)/){
			$opcode = oct("0b".$1);	#convert to number
			$opcode = sprintf('%0x', $opcode);   # Convert back to hex
		}
		$ins_map{$ins_word} = $opcode ;
	}
}
close(DATA);
#print Dumper(\%ins_map);

#parse asm file

#remove comments
system("sed -i 's/;;.*//' $input_file");

#remove white space
system("sed -i '/^\$/d' $input_file");

open(INP, "<$input_file") or die "Couldn't open file $input_file, $!";
open(OUT, ">$output_file") or die "Couldn't open file $output_file, $!";
while(my $line = <INP>){
	
	my ($opcode, $arg) = ($line =~ /(\w+)/g);
	$opcode = uc $opcode;
	$opcode = $ins_map{$opcode};
	$mem[$mem_ptr] = oct("0x".$opcode);
	$mem_ptr+=1;
	$code_byte_size+=1;
	if(defined $arg){
		if($arg =~ /0x(\w+)/i){
			$arg = oct($arg);
		} elsif($arg =~ /(0b\w+)/i){
			#$arg = sprintf('%0x', oct($1));
			$arg = oct($arg);
		}
		$mem[$mem_ptr] = int($arg);
		$mem_ptr+=1;
		$code_byte_size+=1;
	}
}

#printf ("@mem\nsize mem: %d\n", scalar @mem);
#randomize remaining entries
if($randomize){
	for(; $mem_ptr < $memory_depth; $mem_ptr+=1){
		$mem[$mem_ptr] = rand($max_val);
	}
}
#print to file
for(my $i=0; $i<$memory_depth; $i+=1){
	my $hex = sprintf("%02x", $mem[$i]);
	printf OUT "$hex\n";
	print("$hex\t");
}



close(INP);
close(OUT);

print "\n";
print "===========================================================\n";
print "===========================================================\n";
print "===========================================================\n";
system("cat $input_file");
print "===========================================================\n";
print "===========================================================\n";
print "===========================================================\n";

print "Program size = $code_byte_size\n";
print "Output file: $output_file\n" ;

`rm -rf $input_file` if($delete_tmp);

1;
