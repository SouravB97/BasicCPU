`ifndef OPCODEWORD_ALU_OPCODE_WIDTH
	`define OPCODEWORD_ALU_OPCODE_WIDTH 		5
`endif
//combines a register with ALU inputs to make an accumultor to be used in CPU
//optionally can be used to attach any combinational logic element in the register feedback path
//control unit must make sure OPCODE == LD during WE
module accumulator #(
	parameter DATA_WIDTH = `DATA_WIDTH)(
	input clk, reset,
	input CS, WE, OE, ALU_EN,
	input [DATA_WIDTH-1:0] alu_input,			//connect to ALU input PORT B
	input  [OPCODE_WIDTH-1:0] alu_opcode,
	output [STATUS_WIDTH-1:0] alu_status,
	output [DATA_WIDTH-1:0] data_out,
	inout  [DATA_WIDTH-1:0] data
);

	localparam OPCODE_WIDTH = `OPCODEWORD_ALU_OPCODE_WIDTH;
	localparam STATUS_WIDTH = 4;

	wire [DATA_WIDTH-1:0] D,Q;
	wire [DATA_WIDTH-1:0] alu_portC, alu_portB, alu_portA;			//connect to ALU output PORT X

	assign alu_portA = Q;
	assign alu_portB = alu_input;
	assign data_out = Q;

	ALU alu(
		.A(alu_portA), .B(alu_portB),
		.opcode(alu_opcode), 
		.C(alu_portC), .status(alu_status)
	);

	genvar i;
	generate
		for(i=0; i< DATA_WIDTH; i= i+1) begin
			//dff
			d_ff dff(.clk(clk & (WE | ALU_EN)), .reset(reset),
								.D(D[i]), .Q(Q[i]));

			//tristate gate
			tranif1(Q[i], data[i], CS & OE);	//output

			assign D[i] = (ALU_EN & alu_portC[i]) | (WE & data[i]);
		end
	endgenerate
endmodule

