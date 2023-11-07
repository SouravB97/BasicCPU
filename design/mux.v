module mux
#(parameter SIZE = 2,
	parameter TRI_STATE_MUX = 1)(
	input [SIZE - 1:0] D,
	input [SEL_WIDTH - 1: 0] S,	
	output Y
);
	localparam SEL_WIDTH = $clog2(SIZE);

	if(SIZE ==2)
		mux_2x1 #(TRI_STATE_MUX) stage0_mux(.D(D), .S(S), .Y(Y));
	else begin
		wire[1:0] stage0_in;
		
		mux #(.SIZE(SIZE/2)) stage1_mux0 (
			.D(D[SIZE -1: SIZE/2]),
			.S(S[SEL_WIDTH-2 : 0]),
			.Y(stage0_in[1]));

		mux #(.SIZE(SIZE/2)) stage1_mux2 (
			.D(D[SIZE/2 -1: 0]),
			.S(S[SEL_WIDTH-2 : 0]),
			.Y(stage0_in[0]));

		mux_2x1 #(TRI_STATE_MUX) stage0_mux(.D(stage0_in), .S(S[SEL_WIDTH-1]), .Y(Y));
	end

endmodule

//2x1 mux
module mux_2x1
#(parameter TRI_STATE_MUX = 1)
(input [1:0] D, input S, output Y);
	if(TRI_STATE_MUX == 1) begin
		tranif0(D[0], Y, S);
		tranif1(D[1], Y, S);
	end else begin
		wire a = D[1] & S;
		wire b = D[0] & ~S;
		assign Y = a | b;
	end
endmodule

//2x1 switch
module switch_2x1
#(parameter DATA_WIDTH = `DATA_WIDTH)(
	input [SIZE*DATA_WIDTH -1:0] data_in,
	input [SEL_WIDTH-1:0] S,
	output [DATA_WIDTH -1:0] data_out
);
	localparam SIZE = 2;
	localparam SEL_WIDTH = $clog2(SIZE);
	genvar i;
	generate
		for(i=0;i<DATA_WIDTH;i=i+1) begin
			mux #(.SIZE(SIZE)) m(.D({data_in[1*DATA_WIDTH + i],data_in[0*DATA_WIDTH + i]}), .S(S), .Y(data_out[i]));
		end
	endgenerate
endmodule

//Nx1 switch : Recursive
module switch
#(parameter DATA_WIDTH = `DATA_WIDTH,
	parameter SIZE = 2)(
	input [SIZE*DATA_WIDTH -1:0] data_in,
	input [SEL_WIDTH-1:0] S,
	output [DATA_WIDTH -1:0] data_out
);
	;
	localparam SEL_WIDTH = $clog2(SIZE);
	if(SIZE == 2)
		switch_2x1 #(.DATA_WIDTH(DATA_WIDTH)) stage0_switch(.data_in(data_in), .S(S), .data_out(data_out));
	else begin
		wire[DATA_WIDTH-1:0] stage0_in1;
		wire[DATA_WIDTH-1:0] stage0_in0;
		
		switch #(.SIZE(SIZE/2), .DATA_WIDTH(DATA_WIDTH)) stage1_switch0 (
			.data_in(data_in[SIZE*DATA_WIDTH -1: (SIZE/2)*DATA_WIDTH]),
			.S(S[SEL_WIDTH-2 : 0]),
			.data_out(stage0_in1)
		);

		switch #(.SIZE(SIZE/2), .DATA_WIDTH(DATA_WIDTH)) stage1_switch1 (
			.data_in(data_in[(SIZE/2)*DATA_WIDTH -1: 0]),
			.S(S[SEL_WIDTH-2 : 0]),
			.data_out(stage0_in0)
		);

		switch_2x1 #(.DATA_WIDTH(DATA_WIDTH)) stage0_switch(
			.data_in({stage0_in1, stage0_in0}), 
			.S(S[SEL_WIDTH-1]), 
			.data_out(data_out)
		);
	end
endmodule

//N bit array of muxes.
//useful for bus decode logic
module mux_array
#(parameter DATA_WIDTH = `DATA_WIDTH,
  parameter SIZE = 4,
  parameter SEL_WIDTH = $clog2(SIZE))(
	//input [DATA_WIDTH-1:0][SIZE-1:0] D,
	input [DATA_WIDTH * SIZE -1 : 0] D,
	input [SEL_WIDTH - 1: 0] S,	
	output [DATA_WIDTH-1:0] Y
);
	//ICARUS VERILOG LIMITATION wire[DATA_WIDTH-1:0][SIZE-1:0] d;
	//ICARUS VERILOG LIMITATION for(i=0; i<SIZE; i=i+1) begin
	//ICARUS VERILOG LIMITATION 	for(j=0; j<SIZE; j=j+1) begin
	//ICARUS VERILOG LIMITATION 		d[i][j] = D[i + (j*DATA_WIDTH)];
	//ICARUS VERILOG LIMITATION 	end
	//ICARUS VERILOG LIMITATION end

	genvar i;
	generate
		for(i=0; i< DATA_WIDTH; i=i+1) begin

			//manually add code for Nx1 mux array
			if(SIZE == 4) //4x1 mux array
				mux #(.SIZE(SIZE)) m(.D({D[i + (3*DATA_WIDTH)],D[i + (2*DATA_WIDTH)],D[i + (1*DATA_WIDTH)],D[i + (0*DATA_WIDTH)]}), .S(S), .Y(Y[i]));
			else if(SIZE == 2) //2x1 mux array
				mux #(.SIZE(SIZE)) m(.D({D[i + (1*DATA_WIDTH)],D[i + (0*DATA_WIDTH)]}), .S(S), .Y(Y[i]));
			else begin	//Nx1 mux array
				wire[SIZE-1:0] d;
				//d = ?? // can't assign anything to d thanks to icarus
				mux #(.SIZE(SIZE)) m(.D(d), .S(S), .Y(Y[i]));
			end

		end
	endgenerate
endmodule

//Verilog doesn't allow an I/O port to be a 2-D array.
//In Verilog 2001 you could flatten your array into a vector and pass that through the port, but that's somewhat awkward.
//DOESNT WORK module switch
//DOESNT WORK #(
//DOESNT WORK 	parameter DATA_WIDTH = `DATA_WIDTH,
//DOESNT WORK 	parameter SIZE = 2
//DOESNT WORK )(
//DOESNT WORK 	input[SIZE*DATA_WIDTH-1:0] data_in,
//DOESNT WORK 	input[SEL_WIDTH-1:0] S,
//DOESNT WORK 	output[DATA_WIDTH-1:0] data_out	
//DOESNT WORK );
//DOESNT WORK 	localparam SEL_WIDTH = $clog2(SIZE);
//DOESNT WORK 	wire[DATA_WIDTH-1:0] data_in_arr [0:SIZE-1];
//DOESNT WORK 
//DOESNT WORK 	genvar N;
//DOESNT WORK 	generate
//DOESNT WORK 		for(N =0; N<SIZE; N=N+1) begin : DATA_IN
//DOESNT WORK 			assign data_in_arr[N] = data_in[(N+1)*DATA_WIDTH -1 : N*(DATA_WIDTH)];
//DOESNT WORK 		end
//DOESNT WORK 	endgenerate
//DOESNT WORK 
//DOESNT WORK 	genvar i,j;
//DOESNT WORK 	generate
//DOESNT WORK 		for(i=0;i<DATA_WIDTH;i=i+1) begin	: MUX
//DOESNT WORK 			wire[SIZE-1:0] D;
//DOESNT WORK 			//BREAKS ICARUS VERILOG COMPILER  for(j=0;i<SIZE;j=j+1) begin
//DOESNT WORK 			//BREAKS ICARUS VERILOG COMPILER  	assign D[j] = data_in_arr[j][i];
//DOESNT WORK 			//BREAKS ICARUS VERILOG COMPILER  	//assign D[j] = data_in[j*DATA_WIDTH+i];
//DOESNT WORK 			//BREAKS ICARUS VERILOG COMPILER  end
//DOESNT WORK 			mux #(.SIZE(SIZE)) m (.D(D), .S(S), .Y(data_out[i]));
//DOESNT WORK 		end
//DOESNT WORK 	endgenerate
//DOESNT WORK 
//DOESNT WORK endmodule

