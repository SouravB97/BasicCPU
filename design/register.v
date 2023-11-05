
module register
#(parameter DATA_WIDTH = `DATA_WIDTH,
	parameter TYPE = 0	//0: regular register, 1: data_in for input
)(
	input clk, reset,
	input CS, WE, OE,
	input [DATA_WIDTH-1:0] data_in,
	output [DATA_WIDTH-1:0] data_out,
	inout [DATA_WIDTH-1:0] data
);
	wire [DATA_WIDTH-1:0] D,Q;
	wire [DATA_WIDTH-1:0] data_in_type = (TYPE == 0) ? data : data_in;
	assign data_out = Q;

	genvar i;

	generate
		for(i=0; i< DATA_WIDTH; i= i+1) begin
			//dff
			d_ff dff(.clk(clk & WE & CS), .reset(reset),
								.D(D[i]), .Q(Q[i]));

			//tristate gate
			tranif1(data_in_type[i], D[i], CS & WE); //input
			tranif1(Q[i], data[i], CS & OE); //output
		end
	endgenerate
endmodule

//Address register
//16 bit register designed to be used as Address registers
//It has an output data bus called "address" to be conected to the address bus
//"address" contains the 16 bit data when OE_A goes high
module ar_register
#(parameter ADDR_WIDTH = 2*`DATA_WIDTH)(
	input clk, reset,
	input CS, OE_A,
	input WE_L, OE_L, WE_H, OE_H,
	inout [DATA_WIDTH-1:0] data,
	output [ADDR_WIDTH-1:0] address
);
	localparam DATA_WIDTH = ADDR_WIDTH/2;
	wire [DATA_WIDTH-1:0] addr_l, addr_h;

	register #(.DATA_WIDTH(DATA_WIDTH)) reg_l (
		.clk(clk), .reset(reset),
		.data(data), .data_out(addr_l),
		.CS(CS),.WE(WE_L),.OE(OE_L)
	);

	register #(.DATA_WIDTH(DATA_WIDTH)) reg_h (
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

