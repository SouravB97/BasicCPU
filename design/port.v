//A port is a bunch of memory mapped IO registers
//It has N GPIO pins which connect to the outside world
//0x00: PORT register: for receiving input and output
//0x01: PDDR register: (Port data direction register.) 0:input, 1: output
//0x02: RSVD: For future PULLUP_EN support
//0x03: reserved
module port
#(parameter DATA_WIDTH = `DATA_WIDTH)(
	input clk, reset,
	input CS, WE, OE,
	input [DATA_WIDTH-1:0] data_in,
	output [DATA_WIDTH-1:0] data_out
);
	wire [DATA_WIDTH-1:0] D,Q;

	genvar i;

	generate
		for(i=0; i< DATA_WIDTH; i= i+1) begin
			//dff
			d_ff dff(.clk(clk), .reset(reset),
								.D(D[i]), .Q(Q[i]));
			//latch
			latch l1(.D(data_in[i]), .Q(D[i]), .EN(CS & WE));

			//tristate gate
			tranif1(Q[i], data_out[i], CS & OE);
		end
	endgenerate
endmodule
