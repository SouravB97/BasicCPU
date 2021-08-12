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


//A special register who's data contents are always visible on an iadditional output data lines
//It's designed to be used with any register connected as an inpt to the ALU
module ac_register
#(parameter DATA_WIDTH = `DATA_WIDTH)(
	input clk, reset,
	input CS, WE, OE,
	inout [DATA_WIDTH-1:0] data,
	output [DATA_WIDTH-1:0] data_out
);
	wire [DATA_WIDTH-1:0] D,Q;
	assign data_out = Q;

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



//Address register
//16 bit register designed to be used as Address registers
module ar_register
#(parameter DATA_WIDTH = `DATA_WIDTH,
  parameter ADDR_WIDTH = 2*DATA_WIDTH)(
	input clk, reset,
	input CS, OE_A,
	input WE_L, OE_L, WE_H, OE_H,
	inout [DATA_WIDTH-1:0] data,
	output [ADDR_WIDTH-1:0] address
);
	wire [DATA_WIDTH-1:0] addr_l, addr_h;

	ac_register #(.DATA_WIDTH(DATA_WIDTH)) reg_l (
		.clk(clk), .reset(reset),
		.data(data), .data_out(addr_l),
		.CS(CS),.WE(WE_L),.OE(OE_L)
	);

	ac_register #(.DATA_WIDTH(DATA_WIDTH)) reg_h (
		.clk(clk), .reset(reset),
		.data(data), .data_out(addr_h),
		.CS(CS),.WE(WE_H),.OE(OE_H)
	);

	tri_state_buffer #(.DATA_WIDTH(2*DATA_WIDTH)) tsb(
		.data_in({addr_h, addr_l}),
		.data_out(address),
		.OE(OE_A)
	);


endmodule


