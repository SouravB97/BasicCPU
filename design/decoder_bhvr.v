
module decoder
	#(parameter WIDTH = 3)(
	input  [WIDTH -1 :0] S,
	input EN,
	output [(2 ** WIDTH) -1 : 0] D
);
	
	assign D = EN ? 1 << S : 0;

endmodule
