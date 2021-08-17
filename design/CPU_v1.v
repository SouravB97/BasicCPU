module CPU(
	input clk, reset, hlt,
	inout [7:0] PORTA, PORTB, PORTC, PORTD
);
	wire [7:0] data_bus; 
	wire [15:0] address_bus;

	//========================= CONTROL UNIT OUTPUTS =====================================
	//Control outputs for Data bus
	wire WE_A, WE_B, WE_R0, WE_R1, WE_IR0, WE_IR1, WE_PORTA, WE_PORTB, WE_PORTC, WE_PORTD, WE_AR0, WE_AR1, WE_PC0, WE_PC1, WE_SP0, WE_SP1, WE_M;
	wire OE_A, OE_B, OE_R0, OE_R1, OE_IR0, OE_IR1, OE_PORTA, OE_PORTB, OE_PORTC, OE_PORTD, OE_AR0, OE_AR1, OE_PC0, OE_PC1, OE_SP0, OE_SP1, OE_M;
	wire OE_SR, OE_ALU;
	wire OE_AR, OE_PC, OE_SP, OE_R0R1;
	wire [4:0] alu_opcode;

	//========================= random wires in CPU =====================================
	wire[7:0] alu_in0, alu_in1, alu_out;
	wire[3:0] alu_status;
	wire[15:0] instr_data;
	
	//========================= CPU Registers =====================================

	//Accumulator
	ac_register #(.DATA_WIDTH(8)) AC (
		.clk(clk), .reset(reset),
		.data(data_bus), .data_out(alu_in0),
		.CS(1'b1),.WE(WE_A),.OE(OE_A)
	);
		
	//B register
	ac_register #(.DATA_WIDTH(8)) B_reg (
		.clk(clk), .reset(reset),
		.data(data_bus), .data_out(alu_in1),
		.CS(1'b1),.WE(WE_A),.OE(OE_A)
	);

	//16 bit R0 R1 pair.
	//Can be used to address memory directly
	ar_register #(.ADDR_WIDTH(16)) R1R0_pair(
		.clk(clk), .reset(reset),
		.data(data_bus), .address(address_bus),
		.CS(1'b1),.OE_A(OE_R0R1),
		.WE_H(WE_R1),.OE_H(OE_R1),
		.WE_L(WE_R0),.OE_L(OE_R1)
	);

	//status register
	st_register #(.DATA_WIDTH(4)) status_reg(
		.clk(clk), .reset(reset),
		.data_out(data_bus[3:0]), .data_in(alu_status),
		.CS(1'b1), .WE(1'b1), .OE(OE_SR)
	);

	//Instruction register (Connects to instruction decoder)
	ar_register #(.ADDR_WIDTH(16)) instr_reg(
		.clk(clk), .reset(reset),
		.data(data_bus), .address(instr_data),
		.CS(1'b1),.OE_A(1'b1),
		.WE_H(WE_IR1),.OE_H(OE_IR1),
		.WE_L(WE_IR0),.OE_L(OE_IR0)
	);

	//========================= ALU =====================================
	ALU alu(
		.A(alu_in0), .B(alu_in1),
		.opcode(alu_opcode), 
		.C(alu_out), .status(alu_status)
	);
	tri_state_buffer #(.DATA_WIDTH(8)) alu_tsb(
		.data_in(alu_out), .data_out(data_bus),
		.OE(OE_ALU)
	);

	//========================= Address Registers =====================================
	//Address register AR
	ar_register #(.ADDR_WIDTH(16)) AR(
		.clk(clk), .reset(reset),
		.data(data_bus), .address(address_bus),
		.CS(1'b1),.OE_A(OE_AR),
		.WE_H(WE_AR1),.OE_H(OE_AR1),
		.WE_L(WE_AR0),.OE_L(OE_AR0)
	);
	//Programme Counter PC
	ar_register #(.ADDR_WIDTH(16)) PC(
		.clk(clk), .reset(reset),
		.data(data_bus), .address(address_bus),
		.CS(1'b1),.OE_A(OE_PC),
		.WE_H(WE_PC1),.OE_H(OE_PC1),
		.WE_L(WE_PC0),.OE_L(OE_PC0)
	);
	//Stack pointer SP
	ar_register #(.ADDR_WIDTH(16)) SP(
		.clk(clk), .reset(reset),
		.data(data_bus), .address(address_bus),
		.CS(1'b1),.OE_A(OE_SP),
		.WE_H(WE_SP1),.OE_H(OE_SP1),
		.WE_L(WE_SP0),.OE_L(OE_SP0)
	);
	//========================= PORTS =====================================

	//========================= Memory =====================================
	memory #(.DEPTH(32768)) RAM(.clk(clk), .reset(reset), .address(address_bus[14:0]), .data(data_bus), .OE(OE_M), .WE(WE_M), .CS(~address_bus[15]));

	//========================= Instruction Decoder =====================================

	//========================= Control Unit =====================================

endmodule
