`include "includes.v"

module CPU_tb();
	reg clk, reset;
	wire clk_out;

	parameter clk_period = 10;
	integer i;

	always #(clk_period/2) clk = ~clk;

	//========================= CONTROL UNIT OUTPUTS =====================================
	wire[63:0] control_bus;
	wire[7:0] data_bus;
	//Control outputs for Data bus
	reg WE_A, WE_B, WE_R0, WE_R1, WE_IR0, WE_IR1, WE_AR0, WE_AR1, WE_PC0, WE_PC1, WE_SP0, WE_SP1, WE_M;
	reg OE_A, OE_B, OE_R0, OE_R1, OE_IR0, OE_IR1, OE_AR0, OE_AR1, OE_PC0, OE_PC1, OE_SP0, OE_SP1, OE_M;
	reg OE_SR, OE_ALU, PC_INR;
	//Control outputs for address bus
	reg OE_AR, OE_PC, OE_SP, OE_R0R1;
	reg [4:0] alu_opcode, MID, SID; //data bus master/slave ID
	reg [1:0] AMID; //address master ID
	wire sign, zero, parity, carry;
	reg[7:0] data = 'hzz;

	assign data_bus = data;

	//control bus
	assign control_bus = {
	  sign, zero, parity, carry,
		MID, SID, AMID,
		alu_opcode, 
		OE_AR, OE_PC, OE_SP, OE_R0R1,
		OE_SR, OE_ALU, PC_INR,
		OE_A, OE_B, OE_R0, OE_R1, OE_IR0, OE_IR1, OE_AR0, OE_AR1, OE_PC0, OE_PC1, OE_SP0, OE_SP1, OE_M,
		WE_A, WE_B, WE_R0, WE_R1, WE_IR0, WE_IR1, WE_AR0, WE_AR1, WE_PC0, WE_PC1, WE_SP0, WE_SP1, WE_M
	};


	//instantiate DUT
	CPU cpu(.clk(clk), .reset(reset), .control_bus(control_bus), .data_bus(data_bus));
	

	initial begin
		$dumpfile("../dump/CPU_tb.vcd");
		$dumpvars(0,CPU_tb);
		$timeformat(-9, 2, " ns", 20);

		clk <=0;
		reset <=0;
		$printtimescale;

	{
		MID, SID, AMID,
		alu_opcode, 
		OE_AR, OE_PC, OE_SP, OE_R0R1,
		OE_SR, OE_ALU, PC_INR,
		OE_A, OE_B, OE_R0, OE_R1, OE_IR0, OE_IR1, OE_AR0, OE_AR1, OE_PC0, OE_PC1, OE_SP0, OE_SP1, OE_M,
		WE_A, WE_B, WE_R0, WE_R1, WE_IR0, WE_IR1, WE_AR0, WE_AR1, WE_PC0, WE_PC1, WE_SP0, WE_SP1, WE_M
	} = 0;
	
		//wait for 1 clock cycle before asserting reset, so that registers are initialised to 0
		@(posedge clk);
		@(negedge clk);
		reset = 1'b1;
	end


	initial begin

		cpu.control_ROM.print_mem();
		#34;
		//set PC as certain memory location
//		MVI('h69, 2);
		fetch();
		#34;
//		MOV(0,2);
//		MOV(1,3);
//		fetch();
//		fetch();
//		MOV(0,4);
//		MOV(1,5);
//		MOV(2,3);

		#100;
		$display("Instruction reg = %0h", cpu.instr_reg.tsb.data_in);		
		$finish();
	end

	task fetch();
		begin
			//@(negedge clk); //T0
			OE_PC <= 1;
			OE_M  <= 1;
			@(negedge clk); //T1
			WE_IR0 <= 1;
			PC_INR <= 1;
			@(negedge clk); //T2
			WE_IR0 <= 0;
			PC_INR <= 0;
			@(negedge clk); //T3
			WE_IR1 <= 1;
			PC_INR <= 1;
			@(negedge clk); //T4
			OE_PC <= 0;
			OE_M  <= 0;
			WE_IR1 <= 0;
			PC_INR <= 0;
		end
	endtask

	task MOV;
		input[3:0] R1, R2;
		reg OE, WE;
//		MID	|	Register
//		0	|	IR0	
//		1	|	IR1
//		2	|	A
//		3	|	B
//		4	|	Mem
//		5	|	R0
//		6	|       R1
//		7	|       AR0
//		8	|	AR1
//		9	|	PC0
//		10	|	PC1
//		11	|	SP0
//		12	|	SP1

//		SID	|	Register
//		0	|	IR0	
//		1	|	IR1
//		2	|	A
//		3	|	B
//		4	|	Mem
//		5	|	R0
//		6	|       R1
//		7	|       AR0
//		8	|	AR1
//		9	|	PC0
//		10	|	PC1
//		11	|	SP0
//		12	|	SP1
//		17	|	SR
//		18	|	ALU
		begin

			WE=0;
			OE=0;

			case(R1)
				0:	assign OE_IR0 = OE;
				1:	assign OE_IR1 = OE;
				2:	assign OE_A = OE;
				3:	assign OE_B = OE;
				4:	assign OE_M = OE;
				5:	assign OE_R0 = OE;
				6:	assign OE_R1 = OE;
				7:	assign OE_AR0 = OE;
				8:	assign OE_AR1 = OE;
				9:	assign OE_PC0 = OE;
				10:	assign OE_PC1 = OE;
				11:	assign OE_SP0 = OE;
				12:	assign OE_SP1 = OE;
				13: assign OE_SR  = OE;
				14: assign OE_ALU  = OE;
			endcase

			case(R2)
				0:	assign WE_IR0 = WE;
				1:	assign WE_IR1 = WE;
				2:	assign WE_A = WE;
				3:	assign WE_B = WE;
				4:	assign WE_M = WE;
				5:	assign WE_R0 = WE;
				6:	assign WE_R1 = WE;
				7:	assign WE_AR0 = WE;
				8:	assign WE_AR1 = WE;
				9:	assign WE_PC0 = WE;
				10:	assign WE_PC1 = WE;
				11:	assign WE_SP0 = WE;
				12:	assign WE_SP1 = WE;
			endcase

			//@(negedge clk); //T0
			OE <= 1;
			WE <= 1;
			@(negedge clk); //T1
			OE <= 0;
			WE <= 0;
			#1;

			case(R1)
				0:	deassign OE_IR0;
				1:	deassign OE_IR1;
				2:	deassign OE_A;
				3:	deassign OE_B;
				4:	deassign OE_M;
				5:	deassign OE_R0;
				6:	deassign OE_R1;
				7:	deassign OE_AR0;
				8:	deassign OE_AR1;
				9:	deassign OE_PC0;
				10:	deassign OE_PC1;
				11:	deassign OE_SP0;
				12:	deassign OE_SP1;
				13: deassign OE_SR ;
				14: deassign OE_ALU ;
			endcase

			case(R2)
				0:	deassign WE_IR0;
				1:	deassign WE_IR1;
				2:	deassign WE_A;
				3:	deassign WE_B;
				4:	deassign WE_M;
				5:	deassign WE_R0;
				6:	deassign WE_R1;
				7:	deassign WE_AR0;
				8:	deassign WE_AR1;
				9:	deassign WE_PC0;
				10:	deassign WE_PC1;
				11:	deassign WE_SP0;
				12:	deassign WE_SP1;
			endcase

		end
	endtask

	task MVI;
		input[7:0] value;
		input[3:0] R1;
		reg WE;

//		MID	|	Register
//		0	|	IR0	
//		1	|	IR1
//		2	|	A
//		3	|	B
//		4	|	Mem
//		5	|	R0
//		6	|       R1
//		7	|       AR0
//		8	|	AR1
//		9	|	PC0
//		10	|	PC1
//		11	|	SP0
//		12	|	SP1

		begin

			WE=0;
			case(R1)
				0:	assign WE_IR0 = WE;
				1:	assign WE_IR1 = WE;
				2:	assign WE_A = WE;
				3:	assign WE_B = WE;
				4:	assign WE_M = WE;
				5:	assign WE_R0 = WE;
				6:	assign WE_R1 = WE;
				7:	assign WE_AR0 = WE;
				8:	assign WE_AR1 = WE;
				9:	assign WE_PC0 = WE;
				10:	assign WE_PC1 = WE;
				11:	assign WE_SP0 = WE;
				12:	assign WE_SP1 = WE;
			endcase

			//@(negedge clk); //T0
			data <= value;
			WE <= 1;
			@(negedge clk); //T1
			data <= 'hzz;
			WE <= 0;
			#0.1;//@(posedge clk); //END

			case(R1)
				0:	deassign WE_IR0;
				1:	deassign WE_IR1;
				2:	deassign WE_A;
				3:	deassign WE_B;
				4:	deassign WE_M;
				5:	deassign WE_R0;
				6:	deassign WE_R1;
				7:	deassign WE_AR0;
				8:	deassign WE_AR1;
				9:	deassign WE_PC0;
				10:	deassign WE_PC1;
				11:	deassign WE_SP0;
				12:	deassign WE_SP1;
			endcase

		end
	endtask
//	initial begin
//		$monitor("Time = %0t /t  = %b",$time, clk_div.div_ratio);
//	end

endmodule
