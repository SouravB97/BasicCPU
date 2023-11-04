#!/usr/bin/perl 
use strict;
use warnings;

use List::Util qw(first);
use Data::Dumper;
use Getopt::Long;

my $input_file = "$ENV{STEM}/asm_programmes/bootcode.asm";
my $defines_file = "$ENV{STEM}/design/cpu_defines.vh";
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
my $show_map;
my $help_message = 
"	Help Message	\
	source bootenv to setup ENV vars.
"
;

GetOptions ( 
"f|inp=s" => \$input_file,
"out=s" => 	\$output_file,
"h|help" => 	\$help,
"mem_depth=s" => 	\$memory_depth,
"show" => 	\$show_map,
"rand|randomize" => 	\$randomize
);

if(defined $help){
	print "$help_message";
	exit();
}

print "input file: $input_file\n" ;
print "Output file: $output_file\n" ;

#printf ("@mem\nsize mem: %d\n", scalar @mem);
$output_file =~ s/.asm/.hex/g;

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
print Dumper(\%ins_map) if defined $show_map;
printf ("Total instructions: %d", scalar keys %ins_map);
exit() if defined $show_map ;

#Check syntax error
open(INP, "<$input_file") or die "Couldn't open file $input_file, $!";
my $syntax_errors=0;
while(my $line = <INP>){
	my $match = 0;
	next if($line =~ /^\s*$/);
	next if($line =~ /^\s*;;/);
	$line =~ s/;;.*//;
	foreach my $opcode (keys %ins_map){
		if($line =~ /\b\Q$opcode\E\b/i){
			$match = 1;
			#print "Match found: $opcode : $line\n";
			last;
		}
	}
	if($match == 0){
		$syntax_errors+=1;
		print "Unrecognized keyword in line $. : $line";
	}
}
close(INP);
die "File has $syntax_errors syntax errors" if $syntax_errors;

`cp $input_file $input_file.tmp`;
$input_file = $input_file.".tmp";
#parse asm file

#remove comments
system("sed -i 's/;;.*//' $input_file");

#remove white space
system("sed -i '/^\$/d' $input_file");

open(INP, "<$input_file") or die "Couldn't open file $input_file, $!";
open(OUT, ">$output_file") or die "Couldn't open file $output_file, $!";

#tokenize
read INP, my $file_content, -s INP;
#remove new line
$file_content =~ s/\n/ /g;
my @ins_word = ($file_content =~ /\S+/g);

foreach my $instr (@ins_word){
	$instr = uc $instr;
	if(exists($ins_map{$instr})){
		$mem[$mem_ptr] = oct("0x".$ins_map{$instr});
	} elsif($instr =~ /0X[A-F0-9]+|0B[01]+|[0-9]+/){
		if($instr =~ /0X|0B/){
			$mem[$mem_ptr] = int(oct(lc $instr));
		}	else{
			$mem[$mem_ptr] = int($instr);
		}
	} else {
		die "Invalid instruction at token $code_byte_size\n";
	}
	$mem_ptr+=1;
	$code_byte_size+=1;
}

#printf ("@mem\nsize mem: %d\n", scalar @mem);
#randomize remaining entries
if($randomize){
	for(; $mem_ptr < $memory_depth; $mem_ptr+=1){
		$mem[$mem_ptr] = rand($max_val);
	}
}

print "\n";
print "===========================================================\n";
print "===========================================================\n";
print "===========================================================\n";
system("cat $input_file");
print "===========================================================\n";
print "===========================================================\n";
print "===========================================================\n";
print "@ins_word\n";
print "===========================================================\n";
print "===========================================================\n";
print "===========================================================\n";

#print to file
for(my $i=0; $i<$memory_depth; $i+=1){
	my $hex = sprintf("%02x", $mem[$i]);
	printf OUT "$hex\n";
	printf ("$hex%s", (($i+1) % 16) ? "\t" : "\n");
}
print "\n";
print "===========================================================\n";
print "===========================================================\n";
print "===========================================================\n";

close(INP);
close(OUT);

print "Program size = $code_byte_size\n";
print "Output file: $output_file\n" ;

`rm -rf $input_file` if($delete_tmp);

1;
