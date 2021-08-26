`include "includes.v"

module CPU_tb();
	reg clk, reset;
	wire clk_out;

	parameter clk_period = 10;
	integer i;

	always #(clk_period/2) clk = ~clk;

	//========================= CONTROL UNIT OUTPUTS =====================================
	wire[32:0] control_bus;
	//control bus inputs
	reg [4:0] alu_opcode;
	reg [4:0] MID, SID; //data bus master/slave ID
	reg [1:0] AMID; //address master ID
	reg PC_INR, MID_EN, SID_EN, AMID_EN;

	//control bus
	assign control_bus = {
		alu_opcode, MID, SID, AMID,
		PC_INR, MID_EN, SID_EN, AMID_EN
	};
	


	//instantiate DUT
	CPU cpu(.clk(clk), .reset(reset), .control_bus(control_bus));
	

	initial begin
		$dumpfile("CPU_tb.vcd");
		$dumpvars(0,CPU_tb);
		$timeformat(-9, 2, " ns", 20);

		clk <=0;
		reset <=0;
		$printtimescale;

	 {
		alu_opcode, MID, SID, AMID,
		PC_INR, MID_EN, SID_EN, AMID_EN
	} = 0;
	

		#10 reset = 1'b1;
	end


	initial begin
		#34;
		fetch();
	//	fetch();
	//	fetch();
	//	fetch();
	//	fetch();
	//	fetch();
	//	fetch();
	//	fetch();
	//	fetch();
	//	fetch();
		#100;
		$display("Instruction reg = %0h", cpu.instr_reg.tsb.data_in);
		$finish();
	end

	task fetch();
		begin
			//@(negedge clk); //T0
			AMID <= 0; AMID_EN <= 1; //	OE_PC <= 1;
			MID  <= 4; MID_EN <= 1; //OE_M <=1
			@(negedge clk); //T1
			SID <= 0; SID_EN <= 1; //WE_IR0 <= 1;
			PC_INR <= 1;
			@(negedge clk); //T2
			SID_EN <= 0; //WE_IR0 <= 0;
			PC_INR <= 0;
			@(negedge clk); //T3
			SID <= 1; SID_EN <= 1; //WE_IR1 <= 1;
			PC_INR <= 1;
			@(negedge clk); //T4
			AMID_EN <= 0; //OE_PC <= 0;
			MID_EN <= 0; //OE_M  <= 0;
			SID_EN <= 0; //WE_IR1 <= 0;
			PC_INR <= 0;

		//	//@(negedge clk); //T0
		//	OE_PC <= 1;
		//	OE_M  <= 1;
		//	@(negedge clk); //T1
		//	WE_IR0 <= 1;
		//	PC_INR <= 1;
		//	@(negedge clk); //T2
		//	WE_IR0 <= 0;
		//	PC_INR <= 0;
		//	@(negedge clk); //T3
		//	WE_IR1 <= 1;
		//	PC_INR <= 1;
		//	@(negedge clk); //T4
		//	OE_PC <= 0;
		//	OE_M  <= 0;
		//	WE_IR1 <= 0;
		//	PC_INR <= 0;
		end
	endtask
//	initial begin
//		$monitor("Time = %0t /t  = %b",$time, clk_div.div_ratio);
//	end

endmodule
