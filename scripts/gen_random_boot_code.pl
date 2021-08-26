
my $output_file = "/c/Users/soura/Documents/verilog/testing/testbench/bootcode.hex";
my $depth = 256; #32768;

open(OUT, '>', $output_file) or die "Can't open $output_file";
for(my $i=0; $i<$depth; $i = $i+1){
	my $rand_num = int(rand(255));
	my $hex = sprintf("%02x", $rand_num);
	printf OUT "$hex\n";
	#print("$hex\n");
}

print("Randomistion Done. Output file: $output_file\n");
exec "gvim $output_file";
