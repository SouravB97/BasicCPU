module CPU(
	input clk, reset, hlt,
	inout [7:0] PORTA, PORTB, PORTC, PORTD,
	input [32:0] control_bus
);
	wire [7:0] data_bus; 
	wire [15:0] address_bus;

	//========================= CONTROL UNIT OUTPUTS =====================================
	//Control outputs for Data bus
	wire WE_A, WE_B, WE_R0, WE_R1, WE_IR0, WE_IR1, WE_PORTA, WE_PORTB, WE_PORTC, WE_PORTD, WE_AR0, WE_AR1, WE_PC0, WE_PC1, WE_SP0, WE_SP1, WE_M;
	wire OE_A, OE_B, OE_R0, OE_R1, OE_IR0, OE_IR1, OE_PORTA, OE_PORTB, OE_PORTC, OE_PORTD, OE_AR0, OE_AR1, OE_PC0, OE_PC1, OE_SP0, OE_SP1, OE_M;
	wire OE_SR, OE_ALU;
	//Control outputs for address bus
	wire OE_AR, OE_PC, OE_SP, OE_R0R1;
	//control bus inputs
	wire [4:0] ALU_OPCODE	= control_bus[`CB_ALU_OPCODE_RANGE];
	wire [4:0] MID 				= control_bus[`CB_MID_RANGE]; //data bus master/slave ID
	wire [4:0] SID 				= control_bus[`CB_SID_RANGE]; //data bus master/slave ID
	wire [1:0] AMID				= control_bus[`CB_AMID_RANGE]; //address master ID
	wire MID_EN			= control_bus[`CB_MID_EN_RANGE];
	wire SID_EN			= control_bus[`CB_SID_EN_RANGE];
	wire PC_INR			= control_bus[`CB_PC_INR_RANGE];
	wire HLT				= control_bus[`CB_HLT_RANGE];
	wire CLR_TIMER = control_bus[`CB_CLR_TIMER_RANGE];
;

	//Timing outputs
	wire[7:0] T;

	//========================= random wires in CPU =====================================
	wire[7:0] alu_in0, alu_in1, alu_out, ir0_reg_out;
	wire[3:0] alu_status;
	wire[2:0] timer_out;
	wire PORT_A_CS;

	//control bus
	/*assign {
		ALU_OPCODE, MID, SID, AMID,
		PC_INR, MID_EN, SID_EN
	} = control_bus;*/
	
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
		.CS(1'b1),.WE(WE_B),.OE(OE_B)
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
	/*ar_register #(.ADDR_WIDTH(16), .DATA_WIDTH(8)) instr_reg(
		.clk(clk), .reset(reset),
		.data(data_bus), .address(instr_data),
		.CS(1'b1),.OE_A(1'b1),
		.WE_H(WE_IR1),.OE_H(OE_IR1),
		.WE_L(WE_IR0),.OE_L(OE_IR0)
	);*/
	ac_register #(.DATA_WIDTH(8)) instr_reg0 (
		.clk(clk), .reset(reset),
		.data(data_bus), .data_out(ir0_reg_out),
		.CS(1'b1),.WE(WE_IR0),.OE(1'b0)
	);

	//========================= ALU =====================================
	ALU alu(
		.A(alu_in0), .B(alu_in1),
		.opcode(ALU_OPCODE), 
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
	pc_register #(.ADDR_WIDTH(16)) PC(
		.clk(clk), .reset(reset),
		.data(data_bus), .address(address_bus),
		.CS(1'b1),.OE_A(OE_PC), .CNT_EN(PC_INR),
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
	//PORTA
//	//Address range: 0x8000 to 0x8003
//	port_module PORTA(
//		.clk(clk), .reset(reset), 
//		.address(address_bus[1:0]), .data(data_bus), 
//		.gpio(PORTA),
//		.OE(OE_PORTA), .WE(WE_PORTA), .CS(PORT_A_CS)
//	);
//	assign PORT_A_CS = address_bus[15] & ~(|address_bus[14:2]);

	//========================= Memory =====================================
	//RAM
	/*//Address range: 0x0000 to 0x7FFF
	memory #(.DEPTH(32768)) RAM(
		.clk(clk), .reset(reset), 
		.address(address_bus[14:0]), .data(data_bus), 
		.OE(OE_M), .WE(WE_M), .CS(~address_bus[15])
	); */

	//Address range: 0x8000 to 0x80FF
	memory #(.DEPTH(`MEMORY_DEPTH),
					 .ADDR_WIDTH(8))
	RAM(
		.clk(~clk), .reset(reset), 
		.address(address_bus[7:0]), .data(data_bus), 
		.OE(OE_M), .WE(WE_M), .CS(~address_bus[15])
	);

	//========================= DATA bus Decoders =====================================
	//Slave data_bus ID decode (WE decoder)
	/*
		SID	|	Register
		0	|	IR0	
		1	|	IR1
		2	|	A
		3	|	B
		4	|	Mem
		5	|	R0
		6	|       R1
		7	|       AR0
		8	|	AR1
		9	|	PC0
		10	|	PC1
		11	|	SP0
		12	|	SP1
		13	|	PORTA
		14	|	PORTB
		15	|	PORTC
		16	|	PORTD
	*/
	decoder #(.WIDTH(5)) sid_decoder(
		.S(SID), .EN(SID_EN),
		.D({
			WE_PORTD, WE_PORTC, WE_PORTB, WE_PORTA,
			WE_SP1, WE_SP0, WE_PC1, WE_PC0,
			WE_AR1, WE_AR0, WE_R1, WE_R0,
			WE_M, WE_B, WE_A,
			WE_IR1, WE_IR0
		})
	);

	//Master data_bus ID decode (WE decoder)
	/*
		MID	|	Register
		0	|	IR0	
		1	|	IR1
		2	|	A
		3	|	B
		4	|	Mem
		5	|	R0
		6	|       R1
		7	|       AR0
		8	|	AR1
		9	|	PC0
		10	|	PC1
		11	|	SP0
		12	|	SP1
		13	|	PORTA
		14	|	PORTB
		15	|	PORTC
		16	|	PORTD
		17	|	SR
		18	|	ALU
	*/
	decoder #(.WIDTH(5)) mid_decoder(
		.S(MID), .EN(MID_EN),
		.D({
			OE_ALU, OE_SR,
			OE_PORTD, OE_PORTC, OE_PORTB, OE_PORTA,
			OE_SP1, OE_SP0, OE_PC1, OE_PC0,
			OE_AR1, OE_AR0, OE_R1, OE_R0,
			OE_M, OE_B, OE_A,
			OE_IR1, OE_IR0
		})
	);

	//========================= Address bus Decoders =====================================
	//Master address_bus ID decode (WE decoder)
	//RAM or IO_ports are always the slave. (Memory mapped IO)
	/*
		AMID	|	Register
		0	|	PC	
		1	|	AR
		2	|	SP
		3	|	R0R1

	*/
	decoder #(.WIDTH(2)) amid_decoder(
		.S(AMID), .EN(1'b1),
		.D({
			OE_R0R1, OE_SP, OE_AR, OE_PC	
		})
	);

	//========================= Timing =====================================
	//timer counter
	counter #(.DATA_WIDTH(3)) timer_reg(
		.clk(clk), .reset(reset),
		.data_out(timer_out),
		.CS(1'b1), .CNT_EN(cnt_en_timer), .WE(1'b0), .SYNC_CLR(CLR_TIMER)
	);
	//synchronizing flop
	//d_ff clr_timer_dff (.clk(clk), .reset(reset), .D(control_bus[`CB_CLR_TIMER_RANGE]), .Q(CLR_TIMER));
	d_ff cnt_en_timer_dff(.clk(clk), .reset(reset), .D(~HLT), .Q(cnt_en_timer)); //ensure T[0] at first clk after reset
	decoder #(.WIDTH(3)) timer_decoder(
		.S(timer_out), .EN(en_timer_decoder), .D(T)
	);
	latch en_timer(.D(reset), .EN(clk), .Q(en_timer_decoder)); //ensure T[0] ==0 at reset no posedge clk

	//========================= Control Unit =====================================
	control_unit_m control_unit(
	 	.clk(clk), .reset(reset),
	 	.T(T),
		.ir0_reg_out(ir0_reg_out), .alu_status(alu_status),
	 	.control_bus(control_bus)
	);

endmodule

module control_unit_m(
	input clk, reset,
	input [7:0] T,
	input	[7:0] ir0_reg_out, input [3:0] alu_status,
	output [32:0] control_bus
);

	wire [31:0] DEC_IR0;
	wire [4:0] alu_opcode = ir0_reg_out[`OPCODEWORD_ALU_OPCODE_RANGE];
	wire [4:0] ir0_mid		= ir0_reg_out[`OPCODEWORD_MID_RANGE];
	wire [4:0] ir0_sid		= ir0_reg_out[`OPCODEWORD_SID_RANGE];
	wire instr_decode = ~T[0]; //don't decode at T0,  during opcode fetch

	//========================= Instruction Decoders =====================================
	decoder #(.WIDTH(`OPCODEWORD_ALU_OPCODE_WIDTH)) ir0_decoder(
		.S(ir0_reg_out[`OPCODEWORD_DECODE_RANGE]), .EN(instr_decode),
		.D(DEC_IR0)
	);

	decoder #(.WIDTH(2)) opcode_type_decoder(
		.S(ir0_reg_out[`OPCODEWORD_TYPE_RANGE]), .EN(instr_decode),
		.D({op_is_sys, op_is_alu, op_is_mvi})
	);

	assign control_bus[`CB_SID_EN_RANGE]				= mid_sid_en;
	assign control_bus[`CB_MID_EN_RANGE]				= mid_sid_en;
	//assign control_bus[`CB_PC_INR_RANGE]				= 1;
	assign control_bus[`CB_AMID_RANGE]					= 0;	//OE_PC
	//assign control_bus[`CB_MID_RANGE]						= 4;	//OE_M
	//assign control_bus[`CB_SID_RANGE]						= 0;	//WE_IR0
	assign control_bus[`CB_ALU_OPCODE_RANGE]		= alu_opcode;
	//assign control_bus[`CB_HLT_RANGE]						= 0;
	//assign control_bus[`CB_CLR_TIMER_RANGE]			= 0;

	//FETCH always at T0:T1
	assign control_bus[`CB_PC_INR_RANGE]				= 
				T[0] ? 1'b1
		: 	T[1] ? 1'b1
		: 	T[2] ? 1'b0
		: 	T[3] ? 1'b0
		: 			   1'b0
	;
	assign control_bus[`CB_MID_RANGE]				= 
				T[0] ? 4		//OE_M, Opcode_fetch
		: 	T[1] ? op_is_mvi ? ir0_mid : 15	//OE_M
		: 	T[2] ? 15
		: 	T[3] ? 15
		: 			   15
	;
	assign control_bus[`CB_SID_RANGE]				= 
				T[0] ? 0		//IR0, opcode_fetch
		: 	T[1] ? op_is_mvi ? ir0_sid : 15	//WE_A, B
		: 	T[2] ? 15
		: 	T[3] ? 15
		: 			   15
	;
	assign mid_sid_en				= 
				T[0] ? 1'b1 //OPCODE_FETCH
		:		T[1] ? op_is_mvi ? 1'b1 : 1'b0
		:		T[2] ? 1'b0	
		:		T[3] ? 1'b0	
		: 			   1'b0	
	;
	//BOZO assign control_bus[`CB_ALU_OPCODE_RANGE]				= 
	//BOZO 			T[0] ? alu_opcode
	//BOZO 	: 	T[1] ? alu_opcode
	//BOZO 	: 	T[2] ? alu_opcode
	//BOZO 	: 	T[3] ? alu_opcode
	//BOZO 	: 			 : alu_opcode
	//BOZO ;
	/*assign control_bus[`CB_AMID_RANGE]				= 
				T[0] ? 1'b0	//OE_PC
		: 	T[1] ? 1'b0	//OE_PC
		: 	T[2] ? 1'b0	//OE_PC
		: 	T[3] ? 1'b0	//OE_PC
		: 			   1'b0	//OE_PC
	;
 */
	assign 	control_bus[`CB_HLT_RANGE]			= 
				|T[2:0] ? op_is_sys & DEC_IR0[`DEC_OP(`CPU_INSTR_HLT)] ? 1'b1 :	1'b0
					:    1'b0
	;
	assign control_bus[`CB_CLR_TIMER_RANGE]	= 
				T[0] ? 1'b0
		: 	T[1] ? 
							op_is_mvi ? 1'b1	
					:		op_is_sys &	DEC_IR0[`DEC_OP(`CPU_INSTR_HLT)] ? 1'b0		
								:	1'b1
		: 			   1'b0
	;
endmodule
