module cpu_m(
	input clk, reset, hlt,
	inout [7:0] PORTA, PORTB, PORTC, PORTD,
	input [32:0] control_bus
);
	wire [7:0] data_bus; 
	wire [15:0] address_bus;
	wire [15:0] address_reg;

	//========================= CONTROL UNIT OUTPUTS =====================================
	//Control outputs for Data bus
	wire WE_A, WE_B, WE_R0, WE_R1, WE_IR0, WE_IR1, WE_PORTA, WE_PORTB, WE_PORTC, WE_PORTD, WE_AR0, WE_AR1, WE_PC0, WE_PC1, WE_SP0, WE_SP1, WE_M;
	wire OE_A, OE_B, OE_R0, OE_R1, OE_IR0, OE_IR1, OE_PORTA, OE_PORTB, OE_PORTC, OE_PORTD, OE_AR0, OE_AR1, OE_PC0, OE_PC1, OE_SP0, OE_SP1, OE_M;
	wire OE_SR;
	//Control outputs for address bus
	wire OE_AR, OE_PC, OE_SP, OE_R0R1;
	//control bus inputs
	wire [`OPCODEWORD_ALU_OPCODE_WIDTH-1:0] ALU_OPCODE	= control_bus[`CB_ALU_OPCODE_RANGE];
	wire [`OPCODEWORD_MID_WIDTH-1:0] MID 								= control_bus[`CB_MID_RANGE]; //data bus master/slave ID
	wire [`OPCODEWORD_SID_WIDTH-1:0] SID 								= control_bus[`CB_SID_RANGE]; //data bus master/slave ID
	wire [1:0] AMID																			= control_bus[`CB_AMID_RANGE]; //address master ID
	wire MID_EN																					= control_bus[`CB_MID_EN_RANGE];
	wire SID_EN																					= control_bus[`CB_SID_EN_RANGE];
	wire PC_INR																					= control_bus[`CB_PC_INR_RANGE];
	wire AR_INR																					= control_bus[`CB_AR_INR_RANGE];
	wire HLT																						= control_bus[`CB_HLT_RANGE] | hlt;
	wire CLR_TIMER																			= control_bus[`CB_CLR_TIMER_RANGE];
	wire ALU_EN																					= control_bus[`CB_ALU_EN_RANGE];
;
	//========================= timing and clocks =====================================
	wire clk1 = reset_q & clk;
	wire clk2 = reset_q & ~clk;

	//========================= random wires in CPU =====================================
	wire[7:0] alu_in0, alu_in1, alu_out, ir0_reg_out;
	wire[3:0] alu_status, alu_status_reg;
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
		.clk(clk1), .reset(reset),											//giving ~clk as it should latch A write data
		.data_in(alu_status), .data(alu_status_reg),
		.CS(1'b1), .WE(ALU_EN), .OE(1'b1/*OE_SR*/)
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
		.data(data_bus), .address(address_reg),
		.CS(1'b1),.OE_A(OE_AR), .CNT_EN(AR_INR),
		.WE_H(WE_AR1),.OE_H(OE_AR1),
		.WE_L(WE_AR0),.OE_L(OE_AR0)
	);
	//Programme Counter PC
	pc_register #(.ADDR_WIDTH(16)) PC(
		.clk(clk1), .reset(reset),
		.data(data_bus), .address(address_reg),
		.CS(1'b1),.OE_A(OE_PC), .CNT_EN(PC_INR),
		.WE_H(WE_PC1),.OE_H(OE_PC1),
		.WE_L(WE_PC0),.OE_L(OE_PC0)
	);
	//========================= Address Latch =====================================
	latch #(.DATA_WIDTH(16)) address_latch(
		.D(address_reg),
		.Q(address_bus),
		.EN(clk2 | (reset & ~reset_q))
	);

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
	//Address range: 0x0000 to 0x00FF
	memory #(.DEPTH(`MEMORY_DEPTH),
					 .ADDR_WIDTH(8))
	RAM(
		.clk(clk), .reset(reset), 
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
		== unused ==
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
	//where the magic happens. This is the conductor in the orchestra
	control_unit_m control_unit(
		.clk(clk2), .reset(reset), .hlt(hlt),
		.ir0_reg_out(ir0_reg_out), .alu_status(alu_status_reg),
	 	.control_bus(control_bus)
	);
	//========================= Control Unit =====================================

	//reset delay flops
	d_ff reset_delay0 (.clk(clk), .reset(reset), .D(reset),   .Q(reset_q)); 

endmodule

module control_unit_m(
	input clk, reset, hlt,
	input	[7:0] ir0_reg_out, input [3:0] alu_status,
	output [32:0] control_bus
);

	//timing controls
	wire [1:0] time_cycle;						//CPU time cycle
	wire [3:0] T;											//CPU T states

	wire [`OPCODEWORD_ALU_OPCODE_WIDTH-1:0] alu_opcode = ir0_reg_out[`OPCODEWORD_ALU_OPCODE_RANGE];
	wire [`OPCODEWORD_MID_WIDTH-1:0] ir0_mid				 = ir0_reg_out[`OPCODEWORD_MID_RANGE];
	wire [`OPCODEWORD_SID_WIDTH-1:0] ir0_sid				 = ir0_reg_out[`OPCODEWORD_SID_RANGE];
	wire sign, zero, parity, carry;
	wire [`OPCODEWORD_MID_WIDTH-1:0] t1_mid, t2_mid, t3_mid;
	wire [`OPCODEWORD_SID_WIDTH-1:0] t1_sid, t2_sid, t3_sid;

/*
	Anatomy of instruction word (opcode)
	
	7:6 opcode type
		0 MOV
		1 MVI
		2 ALU
		3 SYSTEM or CJ
	
	For MOV and MVI:
		5:3 SID (3 bit slave ID)	component which gets written. see table for SID decoder
		2:0 MID (3 bit Master ID) component which gets read. see table for MID decoder

	For ALU instructions:
		4:0 (5 bit ALU opcode.) To be passed to ALU. see ALU table

	For SYSTEM instructions:
		5:5 Compare range
			0 True system instruction
			1 Conditional Jump

*/

	//decode instruction: extract useful bits
	wire [31:0] DEC_IR0; 		//Output from instruction decoder
 	wire op_is_mov;					//opcode is Move reg/mem-> reg/mem
 	wire op_is_mvi;					//opcode is Move Immediate instruction. eg. LDA 32H, LDAR0 42. Increment PC on T3 for these.
 	wire op_is_alu;					//opcode is ALU instruction
	wire op_is_others;			//opcode is SYSTEM or conditional jump.
	wire op_is_sys;					//opcode is SYSTEM instruction, HLT, NOP, etc
	wire op_is_cj;					//opcode is conditional jump
  wire op_mid_is_mem;			//move instruction reading from mem

	wire instr_decode;			//Shows decode phase, unused

	assign op_is_sys				 = op_is_others & ~ir0_reg_out[`OPCODEWORD_CJ_RANGE];
	assign op_is_cj 				 = op_is_others & ir0_reg_out[`OPCODEWORD_CJ_RANGE];
	assign op_mid_is_mem		 = ~|(ir0_mid[2:0] ^ `OPCODEWORD_SID_WIDTH'h1); //MID == 1 (MEM)

	assign {sign, zero, parity, carry} = alu_status;
	assign instr_decode = ~|T[1:0]; //don't decode at T[1:0],  during opcode fetch

	wire HLT				= control_bus[`CB_HLT_RANGE] | hlt;
	wire CLR_TIMER	= control_bus[`CB_CLR_TIMER_RANGE];

	//========================= Timer =====================================
	//timer counter
	counter #(.DATA_WIDTH(2)) timer_reg(
		.clk(clk), .reset(reset),
		.data_out(time_cycle),
		.CS(en_timer), .CNT_EN(~HLT), .WE(1'b0), .SYNC_CLR(CLR_TIMER)
	);

	//timing generator
	decoder #(.WIDTH(2)) timer_decoder(
		.S(time_cycle), .EN(en_timer), .D(T)
	);
	d_ff en_timer_dff(.clk(clk), .reset(reset), .D(1'b1), .Q(en_timer)); //no T states when reset

	//========================= Instruction Decoders =====================================
	decoder #(.WIDTH(`OPCODEWORD_ALU_OPCODE_WIDTH)) ir0_decoder(
		.S(ir0_reg_out[`OPCODEWORD_DECODE_RANGE]), .EN(instr_decode),
		.D(DEC_IR0)
	);

	decoder #(.WIDTH(2)) opcode_type_decoder(
		.S(ir0_reg_out[`OPCODEWORD_TYPE_RANGE]), .EN(instr_decode),
		.D({op_is_others, op_is_alu, op_is_mvi, op_is_mov})
	);
	//=============== Logic for supplementary wires ====================
	mux #(.SIZE(4)) cmp_pass_mux1(
		.D({sign, zero, parity, carry}),
		.S(ir0_reg_out[`OPCODEWORD_CMP_CRITERIA_RANGE]),
		.Y(cmp_pass_mux1_out)
	);
	mux #(.SIZE(2)) cmp_pass_mux2(
		.D({~cmp_pass_mux1_out, cmp_pass_mux1_out}),
		.S(ir0_reg_out[`OPCODEWORD_FLIPCMP_RANGE]),
		.Y(cmp_pass)
	);
	//============================== Assign Control Word =====================================
	assign control_bus[`CB_ALU_OPCODE_RANGE]		= alu_opcode;
	assign control_bus[`CB_ALU_EN_RANGE]				= op_is_alu; //LD opcode
	assign control_bus[`CB_SID_EN_RANGE]				= mid_sid_en;
	assign control_bus[`CB_MID_EN_RANGE]				= mid_sid_en;

	//1. CLR_TIMER
	assign control_bus[`CB_CLR_TIMER_RANGE]	=
		(T[2] & ( (op_is_mov & ~op_mid_is_mem) |				//3 cycle MOV
							 op_is_alu  								 |				//ALU always 3 cycle
							(op_is_cj & ~cmp_pass)			 |				//Conditional Jump failed
							(op_is_sys & ~HLT)										//Dont clear timer on HLT
							 )) |	//
		T[3]																						//always clear on T3
	;
	//2. PC_INR
	assign control_bus[`CB_PC_INR_RANGE]	=
		T[1] | 																					//Always increment after opcode fetch
		(T[2] & (op_is_cj & ~cmp_pass)) |								//CJ Failed, skip next byte (operand of CJ)
		(T[3] & op_is_mvi)															//Increment PC after reading operand of MVI
	;
	//3. mid_sid_en																				
	assign mid_sid_en	=																//If 0 tri-states the data bus and stops all reads from it.
		T[1] |																					//Opcode fetch on data bus
		(T[2] & op_is_mov & ~op_mid_is_mem) |						//Only need data bus in T2 during REG RD/WR and MEM WR
		T[3]																						//T3 always mem_rd
	;
	//4. MID																													//use multi bit logic gate using repetetion operator
	assign control_bus[`CB_MID_RANGE] = 
		({`OPCODEWORD_MID_WIDTH{T[1]}} & `OPCODEWORD_MID_WIDTH'h1)	|		//Always read MEM during opcode fetch
		({`OPCODEWORD_MID_WIDTH{T[2]}} & ir0_mid)										|		//MOV_<REG>_DST
		({`OPCODEWORD_MID_WIDTH{T[3]}} & `OPCODEWORD_MID_WIDTH'h1)			//MOV_MEM_<REG>, MVI, CJ(pass)
	;
	//5. SID
	assign control_bus[`CB_SID_RANGE] = 
		({`OPCODEWORD_SID_WIDTH{T[1]}} & `OPCODEWORD_SID_WIDTH'h0)	|		//Always write IR0 during opcode fetch
		({`OPCODEWORD_SID_WIDTH{T[2]}} & ir0_sid)										|		//MOV_<REG>_DST
		({`OPCODEWORD_SID_WIDTH{T[3]}} & t3_sid)
	;
	//Multi-bit switches for SID_range
	switch #(.SIZE(2), .DATA_WIDTH(`OPCODEWORD_SID_WIDTH)) t3_sid_switch(
		.data_in({
				`OPCODEWORD_SID_WIDTH'h6,	//CJ cmp pass, Jump, write to PC0
				ir0_sid										//MOV_MEM_<REG>, MVI.
			}),
		.S(op_is_cj & cmp_pass),
		.data_out(t3_sid)
	);
	//6. AR_INR
	assign control_bus[`CB_AR_INR_RANGE]	=
		T[2] & (op_is_sys & DEC_IR0[`DEC_OP(`CPU_INSTR_INC_AR)])
	;
	//7. HLT
	assign control_bus[`CB_HLT_RANGE]			= 
		T[2] & op_is_sys & DEC_IR0[`DEC_OP(`CPU_INSTR_HLT)]
	;
	//8. AMID
	assign control_bus[`CB_AMID_RANGE]				= //single bit, 0:OE_PC 1:OE_AR
		|T[3:2] & op_is_mov
	;
	
endmodule
