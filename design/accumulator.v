
//combines a register with ALU inputs to make an accumultor to be used in CPU
//optionally can be used to attach any combinational logic element in the register feedback path
//control unit must make sure OPCODE == LD during WE
module accumulator #(
	parameter DATA_WIDTH = `DATA_WIDTH)(
	input clk, reset,
	input CS, WE, OE, OPCODE_LE,
	input [DATA_WIDTH-1:0] alu_input,			//connect to ALU input PORT B
	input  [OPCODE_WIDTH-1:0] alu_opcode,
	output [STATUS_WIDTH-1:0] alu_status,
	output [DATA_WIDTH-1:0] data_out,
	inout  [DATA_WIDTH-1:0] data
);

	localparam OPCODE_WIDTH = 5;
	localparam STATUS_WIDTH = 4;

	wire [DATA_WIDTH-1:0] D,Q;
	wire [DATA_WIDTH-1:0] alu_portC, alu_portB, alu_portA;			//connect to ALU output PORT X
	wire [OPCODE_WIDTH-1:0] we_vector, alu_opcode_latched;
	wire [OPCODE_WIDTH-1:0] alu_opcode_port = alu_opcode_latched &
																					 ~{OPCODE_WIDTH{WE}} & 
																					 {OPCODE_WIDTH{OPCODE_LE}}; //LD_OPCODE if WE or not an ALU instruction

	assign D = alu_portC;
	assign data_out = Q;
	assign alu_portB = alu_input;

	ALU alu(
		.A(alu_portA), .B(alu_portB),
		.opcode(alu_opcode_port), 
		.C(alu_portC), .status(alu_status)
	);
	latch #(.DATA_WIDTH(5)) alu_opcode_latch(
		.D(alu_opcode), .Q(alu_opcode_latched),
		.EN(OPCODE_LE)
	);

	genvar i;
	generate
		for(i=0; i< DATA_WIDTH; i= i+1) begin
			//dff
			d_ff dff(.clk(clk), .reset(reset),
								.D(D[i]), .Q(Q[i]));
			//latch
			latch l1(.D(data[i]), .Q(alu_portA[i]), .EN(CS & WE));

			//tristate gate
			tranif1(Q[i], data[i], CS & OE);
		end
	endgenerate
endmodule

