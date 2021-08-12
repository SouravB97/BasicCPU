module mux
#(	parameter DATA_WIDTH = 2,
		parameter SEL_WIDTH = $clog2(DATA_WIDTH))(
	input [DATA_WIDTH - 1:0] D,
	input [SEL_WIDTH - 1: 0] S,	
	output Y
);

	if(DATA_WIDTH ==2)
		tri_state_mux stage0_mux(.D(D), .S(S), .Y(Y));
	else begin
		wire[1:0] stage0_in;
		
		mux #(.DATA_WIDTH(DATA_WIDTH/2)) stage1_mux0 (
			.D(D[DATA_WIDTH -1: DATA_WIDTH/2]),
			.S(S[SEL_WIDTH-2 : 0]),
			.Y(stage0_in[1]));

		mux #(.DATA_WIDTH(DATA_WIDTH/2)) stage1_mux2 (
			.D(D[DATA_WIDTH/2 -1: 0]),
			.S(S[SEL_WIDTH-2 : 0]),
			.Y(stage0_in[0]));

		tri_state_mux stage0_mux(.D(stage0_in), .S(S[SEL_WIDTH-1]), .Y(Y));
	end

endmodule


module tri_state_mux(input [1:0] D, input S, output Y);
	tranif0(D[0], Y, S);
	tranif1(D[1], Y, S);
endmodule

