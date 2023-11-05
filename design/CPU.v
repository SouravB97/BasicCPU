module cpu_m(
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
	wire OE_SR;
	//Control outputs for address bus
	wire OE_AR, OE_PC, OE_SP, OE_R0R1;
	//control bus inputs
	wire [`OPCODEWORD_ALU_OPCODE_WIDTH-1:0] ALU_OPCODE	= control_bus[`CB_ALU_OPCODE_RANGE];
	wire [`OPCODEWORD_MID_WIDTH-1:0] MID 				= control_bus[`CB_MID_RANGE]; //data bus master/slave ID
	wire [`OPCODEWORD_SID_WIDTH-1:0] SID 				= control_bus[`CB_SID_RANGE]; //data bus master/slave ID
	wire [1:0] AMID				= control_bus[`CB_AMID_RANGE]; //address master ID
	wire MID_EN						= control_bus[`CB_MID_EN_RANGE];
	wire SID_EN						= control_bus[`CB_SID_EN_RANGE];
	wire PC_INR						= control_bus[`CB_PC_INR_RANGE];
	wire AR_INR						= control_bus[`CB_AR_INR_RANGE];
	wire HLT							= control_bus[`CB_HLT_RANGE] | hlt;
	wire CLR_TIMER				= control_bus[`CB_CLR_TIMER_RANGE];
	wire ALU_EN						= control_bus[`CB_ALU_EN_RANGE];
;
	//========================= timing and clocks =====================================
	wire clk1 = reset_q & clk;
	wire clk2 = reset_q & ~clk;
	wire clk3 = reset_qq & clk;

	//========================= random wires in CPU =====================================
	wire[7:0] alu_in0, alu_in1, alu_out, ir0_reg_out;
	wire[4:0] alu_opcode_latched;
	wire[3:0] alu_status;
	wire[15:0] address_bus1;

	//========================= Accumulator =====================================
	//Accumulator
	accumulator #(.DATA_WIDTH(8)) A_reg (
		.clk(clk1), .reset(reset),
		.data(data_bus),
		.alu_input(alu_in1),
		.alu_opcode(ALU_OPCODE),
		.alu_status(alu_status),
		.CS(1'b1),.WE(WE_A),.OE(OE_A),.ALU_EN(ALU_EN)
	);
	
	//========================= CPU Registers =====================================
	//B register
	register #(.TYPE(0), .DATA_WIDTH(8)) B_reg (
		.clk(clk1), .reset(reset),
		.data(data_bus), .data_out(alu_in1),
		.CS(1'b1),.WE(WE_B),.OE(OE_B)
	);

	//status register
	register #(.TYPE(1), .DATA_WIDTH(4)) status_reg(
		.clk(clk1), .reset(reset),
		.data(data_bus[3:0]), .data_in(alu_status),
		.CS(1'b1), .WE(1'b1), .OE(1'b0/*OE_SR*/)
	);

	//Instruction register (Connects to instruction decoder)
	register #(.TYPE(0), .DATA_WIDTH(8)) instr_reg0(
		.clk(clk1), .reset(reset),
		.data(data_bus), .data_out(ir0_reg_out),
		.CS(1'b1),.WE(WE_IR0),.OE(OE_IR0)
	);

	//========================= Address Registers =====================================
	//Address register AR
	pc_register #(.ADDR_WIDTH(16)) AR(
		.clk(clk1), .reset(reset),
		.data(data_bus), .address(address_bus),
		.CS(1'b1),.OE_A(OE_AR), .CNT_EN(AR_INR),
		.WE_H(WE_AR1),.OE_H(OE_AR1),
		.WE_L(WE_AR0),.OE_L(OE_AR0)
	);
	//Programme Counter PC
	pc_register #(.ADDR_WIDTH(16)) PC(
		.clk(clk1), .reset(reset),
		.data(data_bus), .address(address_bus),
		.CS(1'b1),.OE_A(OE_PC), .CNT_EN(PC_INR),
		.WE_H(WE_PC1),.OE_H(OE_PC1),
		.WE_L(WE_PC0),.OE_L(OE_PC0)
	);
	//latch
	//latch #(.DATA_WIDTH(16)) address_latch(
	//	.D(address_bus1), .Q(address_bus), .EN(~clk)	
	//);

	//Stack pointer SP
//	ar_register #(.ADDR_WIDTH(16)) SP(
//		.clk(clk1), .reset(reset),
//		.data(data_bus), .address(address_bus),
//		.CS(1'b1),.OE_A(OE_SP),
//		.WE_H(WE_SP1),.OE_H(OE_SP1),
//		.WE_L(WE_SP0),.OE_L(OE_SP0)
//	);
	//========================= PORTS =====================================
	//PORTA
//	//Address range: 0x8000 to 0x8003
//	port_module PORTA(
//		.clk(clk1), .reset(reset), 
//		.address(address_bus[1:0]), .data(data_bus), 
//		.gpio(PORTA),
//		.OE(OE_PORTA), .WE(WE_PORTA), .CS(PORT_A_CS)
//	);
//	assign PORT_A_CS = address_bus[15] & ~(|address_bus[14:2]);

	//========================= Memory =====================================
	//RAM
	//Address range: 0x8000 to 0x80FF
	memory #(.DEPTH(`MEMORY_DEPTH),
					 .ADDR_WIDTH(8))
	RAM(
		.clk(clk2), .reset(reset), 
		.address(address_bus[7:0]), .data(data_bus), 
		.OE(OE_M), .WE(WE_M), .CS(~address_bus[15])
	);
	//assign data_bus = `CPU_INSTR_NOP;

	//========================= DATA bus Decoders =====================================
	//Slave data_bus ID decode (WE decoder)
	/*
		SID	|	Register
		0 	|	IR0	
		1 	|	Mem 
		2 	|	A
		3 	|	B
		4 	|	AR0
		5 	|	AR1 
		6 	| PC0      
		7 	| PC1      

	*/
	decoder #(.WIDTH(3)) sid_decoder(
		.S(SID), .EN(SID_EN),
		.D({
			WE_PC1, WE_PC0,
			WE_AR1, WE_AR0,
			WE_B, WE_A,
			WE_M, WE_IR0
		})
	);

	//Master data_bus ID decode (WE decoder)
	/*
		MID	|	Register
		0 	|	IR0	
		1 	|	Mem 
		2 	|	A
		3 	|	B
		4 	|	AR0
		5 	|	AR1 
		6 	| PC0      
		7 	| PC1      
	*/
	decoder #(.WIDTH(3)) mid_decoder(
		.S(MID), .EN(MID_EN),
		.D({
			OE_PC1, OE_PC0,
			OE_AR1, OE_AR0,
			OE_B, OE_A,
			OE_M, OE_IR0
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

	//========================= Control Unit =====================================
	control_unit_m control_unit(
		.clk(clk2), .reset(reset), .hlt(hlt),
		.ir0_reg_out(ir0_reg_out), .alu_status(alu_status),
	 	.control_bus(control_bus)
	);
	//========================= Control Unit =====================================

	//reset delay flops
	d_ff reset_delay0 (.clk(clk), .reset(reset), .D(reset),   .Q(reset_q)); 
	d_ff reset_delay1 (.clk(clk), .reset(reset), .D(reset_q), .Q(reset_qq)); 

endmodule

module control_unit_m(
	input clk, reset, hlt,
	input	[7:0] ir0_reg_out, input [3:0] alu_status,
	output [32:0] control_bus
);

	//timing controls
	wire [1:0] time_cycle;
	wire [3:0] T;
	wire [3:0] T_edge;

	wire HLT				= control_bus[`CB_HLT_RANGE] | hlt;
	wire CLR_TIMER	= control_bus[`CB_CLR_TIMER_RANGE];

	wire [31:0] DEC_IR0;
	wire [`OPCODEWORD_ALU_OPCODE_WIDTH:0] alu_opcode = ir0_reg_out[`OPCODEWORD_ALU_OPCODE_RANGE];
	wire [`OPCODEWORD_MID_WIDTH-1:0] ir0_mid		= ir0_reg_out[`OPCODEWORD_MID_RANGE];
	wire [`OPCODEWORD_SID_WIDTH-1:0] ir0_sid		= ir0_reg_out[`OPCODEWORD_SID_RANGE];
	wire instr_decode = ~T[0]; //don't decode at T0,  during opcode fetch

	wire op_is_mov_ins = op_is_mov | op_is_mvi ;
	wire op_is_mem	= (op_is_mov_ins) & ~|(ir0_sid[2:0] ^ 3'h1);	//SID is RAM
	wire mid_sid_is_ram	=  |(ir0_sid[2:0] ^ 3'h1) | |(ir0_mid[2:0] ^ 3'h1);	//MID or SID is RAM

	genvar i;
	generate
		for(i=0;i<4;i=i+1)
			assign #0 T_edge[i] = T[i];// & clk;
	endgenerate
	//========================= Timer =====================================
	//timer counter
	counter #(.DATA_WIDTH(2)) timer_reg(
		.clk(clk), .reset(reset),
		.data_out(time_cycle),
		.CS(1'b1), .CNT_EN(~HLT), .WE(1'b0), .SYNC_CLR(CLR_TIMER)
	);

	//timing generator
	decoder #(.WIDTH(2)) timer_decoder(
		.S(time_cycle), .EN(en_timer_decoder), .D(T)
	);
	d_ff en_timer_dff(.clk(clk), .reset(reset), .D(1'b1), .Q(en_timer_decoder)); //ensure T[0] at first clk after reset

	//========================= Instruction Decoders =====================================
	decoder #(.WIDTH(`OPCODEWORD_ALU_OPCODE_WIDTH)) ir0_decoder(
		.S(ir0_reg_out[`OPCODEWORD_DECODE_RANGE]), .EN(instr_decode),
		.D(DEC_IR0)
	);

	decoder #(.WIDTH(2)) opcode_type_decoder(
		.S(ir0_reg_out[`OPCODEWORD_TYPE_RANGE]), .EN(instr_decode),
		.D({op_is_sys, op_is_alu, op_is_mvi, op_is_mov})
	);

	//====================================================================================

	assign control_bus[`CB_SID_EN_RANGE]				= mid_sid_en;
	assign control_bus[`CB_MID_EN_RANGE]				= mid_sid_en;
	assign control_bus[`CB_ALU_OPCODE_RANGE]		= alu_opcode;
	assign control_bus[`CB_ALU_EN_RANGE]				= op_is_alu; //LD opcode

	//FETCH always at T0:T1
	assign control_bus[`CB_PC_INR_RANGE]				= 
				T_edge[0] ? 1'b1
		:		T_edge[1] ? op_is_mvi ? 1'b1 : 1'b0
		: 			   1'b0
	;
	assign control_bus[`CB_MID_RANGE]				= 
				T_edge[0] ? 1		//OE_M, Opcode_fetch
		: 	T_edge[1] ? op_is_mov_ins ? ir0_mid : 15	//OE_M
		: 			   15
	;
	assign control_bus[`CB_SID_RANGE]				= 
				T_edge[0] ? 0		//IR0, opcode_fetch
		: 	T_edge[1] ? op_is_mov_ins ? ir0_sid : 15	//WE_A, B
		: 			   15
	;
	assign mid_sid_en				= 
				T_edge[0] ? 1'b1 //OPCODE_FETCH
		:		T_edge[1] ? op_is_mov_ins ? 1'b1 : 1'b0
		: 			   1'b0	
	;

	assign control_bus[`CB_AMID_RANGE]				= 
				T_edge[0] ? 0	//OE_PC
		: 	T_edge[1] ? op_is_mov & mid_sid_is_ram ? 1	//OE_AR
						 : 0	//OE_PC
		: 			   0	//OE_PC
	;
	assign 	control_bus[`CB_HLT_RANGE]			= 
				|T_edge[2:0] ? op_is_sys & DEC_IR0[`DEC_OP(`CPU_INSTR_HLT)] ? 1'b1 :	1'b0
					:    1'b0
	;
	assign control_bus[`CB_CLR_TIMER_RANGE]	= 
				T_edge[0] ? 1'b0
		: 	T_edge[1] ? 	op_is_sys &	DEC_IR0[`DEC_OP(`CPU_INSTR_HLT)] 	? 1'b0		
								:	1'b1
		: 			   1'b0
	;
	assign control_bus[`CB_AR_INR_RANGE]	= 
				T_edge[0] ? 1'b0
		: 	T_edge[1] ? 	op_is_sys &	DEC_IR0[`DEC_OP(`CPU_INSTR_INC_AR)] 	? 1'b1		
								:	1'b0
		: 			   1'b0
	;
endmodule
