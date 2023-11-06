#!/usr/bin/perl 
use strict;
use warnings;

use List::Util qw(first);
use Data::Dumper;
use Getopt::Long;

my $defines_file = "$ENV{STEM}/design/cpu_defines.vh";
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
my $delete_tmp;
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
	"mem_width=s" => 	\$memory_width,
	"show" => 	\$show_map,
	"remove_temp" => 	\$delete_tmp,
	"rand|randomize" => 	\$randomize
);

if(defined $help){
	print "$help_message";
	exit();
}

#printf ("@mem\nsize mem: %d\n", scalar @mem);
$output_file =~ s/\.asm/.hex/g;

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
		} elsif($pp_in_line eq 'orig'){
			if($line !~ /^\s*#orig\s+(\S+)\s*$/i){
				$syntax_errors+=1;
				print "Unrecognized preprocessor directive in line $. : $line";
				print "\tNo r-value for orig macro\n";
			}

		}
		next;
	}

	#check for opcode
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
die "File has $syntax_errors syntax errors.\n Error in compile " if $syntax_errors;


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
		$define_hash{$1} = $2;
		next;
	}
	#check if anything to substitute from defines
	foreach my $define_key (keys %define_hash){
		if($line =~ /\b\Q$define_key\E\b/){
			$line =~ s/$define_key/$define_hash{$define_key}/;
			last;
		}
	}

	print OUT "$line";
}
	print "Defines:\n";
	print Dumper(\%define_hash);

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
my @ins_word = ($file_content =~ /\S+/g);
#print "@ins_word\n";

for(my $i=0; $i< scalar @ins_word ; $i=$i+1){
	my $instr = uc $ins_word[$i];

	#ORIG directive
	if($instr =~ /#ORIG/){
		$i=$i+1;	
		my $orig_val = uc $ins_word[$i];
		$orig_val = to_int($orig_val);
		$mem_ptr = $orig_val;
	}
	#RISC opcode
	elsif(exists($ins_map{$instr})){
		$mem[$mem_ptr] = oct("0x".$ins_map{$instr});
		$mem_ptr+=1;
		$code_byte_size+=1;
	} 
	#OPCODE arguement
	elsif($instr =~ /0X[A-F0-9]+|0B[01]+|[0-9]+/){
		$mem[$mem_ptr] = to_int($instr);
		$mem_ptr+=1;
		$code_byte_size+=1;
	} else {
		die "Invalid instruction at token $code_byte_size\n";
	}
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

if($delete_tmp){
	`rm -rf $input_file_tmp1 $input_file_tmp2` 
};

sub to_int{
	my $input_str = @_[0];
	my $output_int = 0;
	
	die "Invalid arguement $input_str " if($input_str !~ /0X[A-F0-9]+|[A-F0-9]+H|0B[01]+|[0-9]+/i); 
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
