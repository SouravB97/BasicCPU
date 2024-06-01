#!/usr/bin/perl 
use strict;
use warnings;

use List::Util qw(first);
use Data::Dumper;
use Getopt::Long;

my $defines_file = "$ENV{STEM}/design/instruction_set.vh";
my $pp_directives_file = "$ENV{STEM}/scripts/preprocessor.txt";
my $cisc_instructions_file = "$ENV{STEM}/scripts/cisc_instructions.txt";
my $input_file = "$ENV{STEM}/asm_programmes/bootcode.asm";
my $output_file = $input_file;
my $input_file_tmp1 = $input_file."\.tmp1";
my $input_file_tmp2 = $input_file."\.tmp2";
my %ins_map;
my $comment_char = ';';
my $code_byte_size = 0;
my $memory_depth = 256;
my $memory_width = 1;	#in bytes
my $max_val = 2**($memory_width*8)-1;
my @mem = ($max_val) x $memory_depth;
my $mem_ptr = 0;
my $retain_temps;
my $randomize;
my $help;
my $show_map;
my $help_message;

GetOptions ( 
	"f|inp=s" => \$input_file,
	"out=s" => 	\$output_file,
	"h|help" => 	\$help,
	"mem_depth=s" => 	\$memory_depth,
	"mem_width=s" => 	\$memory_width,
	"show" => 	\$show_map,
	"retain_temps" => 	\$retain_temps,
	"rand|randomize" => 	\$randomize
);


#printf ("@mem\nsize mem: %d\n", scalar @mem);
$output_file =~ s/\.asm/.hex/g;

$help_message = 
"	Help Message	\

	This script assembles the assembly code provided at $input_file and generates object file at $output_file

	Troubleshooting:
	source bootenv to setup ENV vars.

	Usage:
	$0 -inp input_file.asm ;
	$0 -inp $input_file -out $output_file ;
	
	Default output: input_file.hex

	Options:
		f|inp=s		  	:		Pass input assembly file
		out=s					:		Pass output file
		h|help				:		Show this message
		mem_depth=s		:		Pass memory depth. Default is 256
		mem_width=s		:		Pass memory data width. Default is 8
		show					:		Show 
		retain_temps	:		Retain temporary files in $input_file location, called tmp1 and tmp2. Default is off.
		rand|randomize:		Put random values in unused memory locations. Default is pad with FF

"
;
if(defined $help){
	print "$help_message";
	exit();
}

print "input file: $input_file\n" ;
print "Output file: $output_file\n" ;

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
if(defined $show_map) {
	print Dumper(\%ins_map);
	printf ("Total instructions: %d\n", scalar keys %ins_map);
	exit();
}

#Prepare preprocessor
open(DATA, "<$pp_directives_file") or die "Couldn't open file $pp_directives_file, $!";
read DATA, my $pp_file_content, -s DATA;
close(DATA);
my @pp_directives_list = ($pp_file_content =~ /#(\w+)/gm); 
#print "@pp_directives_list\n";
#exit();


print("\n");
#Check syntax error
open(INP, "<$input_file") or die "Couldn't open file $input_file, $!";
my $syntax_errors=0;
while(my $line = <INP>){
	my $match = 0;
	next if($line =~ /^\s*$/);
	next if($line =~ /^\s*$comment_char/);
	$line =~ s/$comment_char.*//;

	#check syntax of labels
	if($line =~ /:/){
		unless($line =~ /\w+\s*:\s*\w+/){
			$syntax_errors+=1;
			print "Incorrect use of label in line $. : $line";
		}
	}

	#check if preprocessor
	if($line =~ /#(\w+)/){
		my $pp_in_line = lc $1;
		#check if valid pre_processor directive
		foreach my $pp_directive (@pp_directives_list){
			if($pp_in_line eq $pp_directive){
				$match = 1;
				last;
			}
		}
		if($match == 0){
			$syntax_errors+=1;
			print "Unrecognized preprocessor directive in line $. : $line";
		}
		#check if preprocessor syntax is correct
		if($pp_in_line eq 'define'){
			if($line !~ /^\s*#define\s+(\S+)\s+(\S+)\s*$/i){
				$syntax_errors+=1;
				print "Unrecognized preprocessor directive in line $. : $line";
				$line =~ /define\s+(\S+)/i;
				print "\tNo r-value for define macro $1\n";
			}
		} elsif($pp_in_line eq ('orig' or 'db')){
			if($line !~ /^\s*#(orig|db)\s+(\S+)\s*$/i){
				$syntax_errors+=1;
				print "Unrecognized preprocessor directive in line $. : $line";
				print "\tNo r-value for $1 macro\n";
			}
		}
		next;
	}

	#check for opcode
	foreach my $opcode (keys %ins_map){
		#if($line =~ /\b\Q$opcode\E\b/i)
		if($line =~ /\Q$opcode\E/i){
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
die "File has $syntax_errors syntax errors.\n Error in compile " if $syntax_errors;
#exit();

#pre-process
`cp $input_file $input_file_tmp1`;

#remove comments
system("sed -i 's/$comment_char.*//' $input_file_tmp1");

#remove white space
system("sed -i '/^\$/d' $input_file_tmp1");

#call pre-processor
my %define_hash;
open(INP, "<$input_file_tmp1") or die "Couldn't open file $input_file_tmp1, $!";
open(OUT, ">$input_file_tmp2") or die "Couldn't open file $input_file_tmp2, $!";

while(my $line = <INP>){
	if($line =~ /^\s*#define\s+(\S+)\s+(\S+)\s*$/i){
		my $key = "`".$1;
		$define_hash{$key} = $2;
		next;
	}
	#check if anything to substitute from defines
	foreach my $define_key (keys %define_hash){
		if($line =~ /\Q$define_key\E/){
			$line =~ s/$define_key/$define_hash{$define_key}/;
			last;
		}
	}
	print OUT "$line";
}

close(INP);
 close(OUT);

#First pass, deal with assembler directives
#`cp $input_file_tmp1 $input_file_tmp2`;
#parse asm file

open(INP, "<$input_file_tmp2") or die "Couldn't open file $input_file_tmp2, $!";
open(OUT, ">$output_file") or die "Couldn't open file $output_file, $!";

#tokenize
read INP, my $file_content, -s INP;
#remove new line
$file_content =~ s/\n/ /g;
my @ins_word = ($file_content =~ /(\S+)/g);
print "@ins_word\n";
my %label_hash;

for(my $i=0; $i< scalar @ins_word ; $i+=1){
	my $instr = uc $ins_word[$i];
	print "\t$i) $instr\n";

	#read labels
	if($instr =~ /(\w+):/){
		my $label = $1;
		die "Label $label is repeated at token $mem_ptr\n" if(exists($label_hash{$label}));
		$label_hash{$label} = $mem_ptr;
		next;
	}
	#Assembler directive
	if($instr =~ /#(\w+)/){
		$i+=1;	
		my $val = to_int(uc $ins_word[$i]);
		if($1 eq "ORIG"){ 
			$mem_ptr = $val;
		} elsif($1 eq "DB"){
			$mem[$mem_ptr] = to_int($val);
		}
		next;
	}
	#RISC opcode
	if(exists($ins_map{$instr})){
		$mem[$mem_ptr] = oct("0x".$ins_map{$instr});
		$mem_ptr+=1;
		$code_byte_size+=1;
		next;
	}
	#substitute labels
	if(exists($label_hash{$instr})){
		$instr = $label_hash{$instr};
	}
	#OPCODE arguement
	if((to_int($instr) != -1)){
		$mem[$mem_ptr] = to_int($instr);
		$mem_ptr+=1;
		$code_byte_size+=1;
		next;
	}
	die "Invalid instruction at token $mem_ptr\n";
}

#printf ("@mem\nsize mem: %d\n", scalar @mem);
#randomize remaining entries
if($randomize){
	for(; $mem_ptr < $memory_depth; $mem_ptr+=1){
		$mem[$mem_ptr] = rand($max_val);
	}
}
print "Defines:\n";
print Dumper(\%define_hash);
print "Labels:\n";
print Dumper(\%label_hash);

print "\n";
print "===========================================================\n";
print "===========================================================\n";
print "===========================================================\n";
system("cat $input_file_tmp2");
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

unless($retain_temps){
	`rm -rf $input_file_tmp1 $input_file_tmp2` 
};

sub to_int{
	my $input_str = $_[0];
	my $output_int = 0;
	
	if($input_str !~ /0X[A-F0-9]+|[A-F0-9]+H|0B[01]+|[0-9]+/i){
		print "Invalid arguement $input_str ";
		return -1;
	}
	if($input_str =~ /0X|0B/i){
		$output_int = int(oct(lc $input_str));
	} elsif ($input_str =~ /([A-F0-9]+)H/i){
		$output_int = int(oct("0x".$1));
	}	else{
		$output_int = int($input_str);
	}

	return $output_int;
}

1;
