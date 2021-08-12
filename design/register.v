//`include "timescale.v"
//`define DATA_WIDTH 8
//`include "d_ff.v"

module register
#(parameter DATA_WIDTH = `DATA_WIDTH)(
	input clk, reset,
	input OE, CS, EN,
	inout [`DATA_WIDTH - 1:0] data
);

	wire [`DATA_WIDTH -1:0] D;
	wire [`DATA_WIDTH -1:0] Q;

	genvar i;
	
	generate
		for(i = 0; i< `DATA_WIDTH; i = i+1) begin
			d_ff dff(.clk(clk), .reset(reset),
							 .D(D[i]),
							 .Q(Q[i]));

			tranif1(Q[i], data[i], CS & OE);
			latch l1(.D(data[i]), .Q(D[i]), .EN(CS & EN));
			//tranif1(data[i], D[i], CS & EN);
		end
	endgenerate

endmodule
