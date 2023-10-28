`include "includes.vh"

module ALU_components_tb();
	reg clk;
	reg a,b,cin;
	parameter clk_period = 10;
	integer i;

	reg [`DATA_WIDTH -1:0] A,B;
	reg [4:0] opcode;
	

	always #(clk_period/2) clk = ~clk;

	//instantiate DUT
	full_adder fa(.A(a), .B(b), .Cin(cin), .S(), .Cout());	
	half_adder ha(.A(a), .B(b), .S(), .Cout());
	SHU shui(
		.A(A), 
		.opcode(opcode[0]),
		.C()
	);
	AU aui(	
		.A(A), .B(B),
		.opcode(opcode[2:0]),
		.Cout(),
		.S()
	);
	LU lui(
		.A(A), .B(B),
		.opcode(opcode[1:0]),
		.S()
	);

	initial begin
		$dumpfile("ALU_components_tb.vcd");
		$dumpvars(0,ALU_components_tb);
		$timeformat(-9, 2, " ns", 20);

		$printtimescale;

	end


	initial begin
		//#100;
		for(i = 0; i < 10; i = i+1) begin
			{a,b,cin} = i[2:0];
			#10;
		end

		for(i =0; i<21; i= i+1) begin
			A = $random;
			B = $random;
			opcode = i;
			#10;
		end

		$finish();
	end

	initial begin
		//$monitor("%b,%b,%b| %b,%b",a,b,cin,ha.S,ha.Cout);
		//$monitor("%b,%b,%b| %b,%b",a,b,cin,fa.S,fa.Cout);
		//$monitor("%b,%b| %b",A,opcode[0],shui.C);
		//$monitor("%d,%d  %b|| %d,%b",A,B,opcode[2:0],aui.S,aui.Cout);
		$monitor("%b,%b  %b|| %b",A,B,opcode[1:0],lui.S);
	end

	function display_tt;
		input[31:0] inputs, outputs;
		input integer range;
		integer i;

		begin
			//$display("INPUTS\t\t\t|OUTPUTS");
			//$display("--------------------");
			//for(i = 0; i < range; i = i+1) begin
				$display("%b\t\t\t|%b",inputs, outputs);
			//end
		end
	endfunction

endmodule
