module register
#(parameter DATA_WIDTH = `DATA_WIDTH)(
	input clk, reset,
	input CS, WE, OE,
	inout [DATA_WIDTH-1:0] data
);
	wire [DATA_WIDTH-1:0] D,Q;

	genvar i;

	generate
		for(i=0; i< DATA_WIDTH; i= i+1) begin
			//dff
			d_ff dff(.clk(clk), .reset(reset),
								.D(D[i]), .Q(Q[i]));
			//latch
			latch l1(.D(data[i]), .Q(D[i]), .EN(CS & WE));

			//tristate gate
			tranif1(Q[i], data[i], CS & OE);
		end
	endgenerate


endmodule
