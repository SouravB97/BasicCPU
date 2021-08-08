
module mux
	#(parameter DATA_WIDTH = 2,
		parameter SEL_WIDTH  = $clog2(DATA_WIDTH))(
		input [DATA_WIDTH -1:0] D,
		input [SEL_WIDTH -1:0] S,
		output Y
	);

	assign Y = D[S];

endmodule

