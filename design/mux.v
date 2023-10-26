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

//N bit array of muxes.
//useful for bus decode logic
module mux_array
#(parameter DATA_WIDTH = `DATA_WIDTH,
  parameter MUX_DATA_WIDTH = 4,
  parameter SEL_WIDTH = $clog2(MUX_DATA_WIDTH))(
	//input [DATA_WIDTH-1:0][MUX_DATA_WIDTH-1:0] D,
	input [DATA_WIDTH * MUX_DATA_WIDTH -1 : 0] D,
	input [SEL_WIDTH - 1: 0] S,	
	output [DATA_WIDTH-1:0] Y
);
	//ICARUS VERILOG LIMITATION wire[DATA_WIDTH-1:0][MUX_DATA_WIDTH-1:0] d;
	//ICARUS VERILOG LIMITATION for(i=0; i<MUX_DATA_WiDTH; i=i+1) begin
	//ICARUS VERILOG LIMITATION 	for(j=0; j<MUX_DATA_WIDTH; j=j+1) begin
	//ICARUS VERILOG LIMITATION 		d[i][j] = D[i + (j*DATA_WIDTH)];
	//ICARUS VERILOG LIMITATION 	end
	//ICARUS VERILOG LIMITATION end

	genvar i;
	generate
		for(i=0; i< DATA_WIDTH; i=i+1) begin

			//manually add code for Nx1 mux array
			if(MUX_DATA_WIDTH == 4) //4x1 mux array
				mux #(.DATA_WIDTH(MUX_DATA_WIDTH)) m(.D({D[i + (3*DATA_WIDTH)],D[i + (2*DATA_WIDTH)],D[i + (1*DATA_WIDTH)],D[i + (0*DATA_WIDTH)]}), .S(S), .Y(Y[i]));
			else if(MUX_DATA_WIDTH == 2) //2x1 mux array
				mux #(.DATA_WIDTH(MUX_DATA_WIDTH)) m(.D({D[i + (1*DATA_WIDTH)],D[i + (0*DATA_WIDTH)]}), .S(S), .Y(Y[i]));
			else begin	//Nx1 mux array
				wire[MUX_DATA_WIDTH-1:0] d;
				//d = ?? // can't assign anything to d thanks to icarus
				mux #(.DATA_WIDTH(MUX_DATA_WIDTH)) m(.D(d), .S(S), .Y(Y[i]));
			end

		end
	endgenerate


endmodule
