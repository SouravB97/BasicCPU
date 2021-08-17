`include "includes.v"

module CPU_tb();
	reg clk, reset;
	wire clk_out;

	parameter clk_period = 10;
	integer i;

	always #(clk_period/2) clk = ~clk;

	//========================= CONTROL UNIT OUTPUTS =====================================
	wire[63:0] control_bus;
	//Control outputs for Data bus
	reg WE_A, WE_B, WE_R0, WE_R1, WE_IR0, WE_IR1, WE_PORTA, WE_PORTB, WE_PORTC, WE_PORTD, WE_AR0, WE_AR1, WE_PC0, WE_PC1, WE_SP0, WE_SP1, WE_M;
	reg OE_A, OE_B, OE_R0, OE_R1, OE_IR0, OE_IR1, OE_PORTA, OE_PORTB, OE_PORTC, OE_PORTD, OE_AR0, OE_AR1, OE_PC0, OE_PC1, OE_SP0, OE_SP1, OE_M;
	reg OE_SR, OE_ALU, PC_INR;
	//Control outputs for address bus
	reg OE_AR, OE_PC, OE_SP, OE_R0R1;
	reg [4:0] alu_opcode, MID, SID; //data bus master/slave ID
	reg [1:0] AMID; //address master ID

	//control bus
	assign control_bus = {
		alu_opcode, MID, SID,
		AMID,
		OE_AR, OE_PC, OE_SP, OE_R0R1,
		OE_SR, OE_ALU, PC_INR,
		OE_A, OE_B, OE_R0, OE_R1, OE_IR0, OE_IR1, OE_PORTA, OE_PORTB, OE_PORTC, OE_PORTD, OE_AR0, OE_AR1, OE_PC0, OE_PC1, OE_SP0, OE_SP1, OE_M,
		WE_A, WE_B, WE_R0, WE_R1, WE_IR0, WE_IR1, WE_PORTA, WE_PORTB, WE_PORTC, WE_PORTD, WE_AR0, WE_AR1, WE_PC0, WE_PC1, WE_SP0, WE_SP1, WE_M
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
		alu_opcode, MID, SID,
		AMID,
		OE_AR, OE_PC, OE_SP, OE_R0R1,
		OE_SR, OE_ALU, PC_INR,
		OE_A, OE_B, OE_R0, OE_R1, OE_IR0, OE_IR1, OE_PORTA, OE_PORTB, OE_PORTC, OE_PORTD, OE_AR0, OE_AR1, OE_PC0, OE_PC1, OE_SP0, OE_SP1, OE_M,
		WE_A, WE_B, WE_R0, WE_R1, WE_IR0, WE_IR1, WE_PORTA, WE_PORTB, WE_PORTC, WE_PORTD, WE_AR0, WE_AR1, WE_PC0, WE_PC1, WE_SP0, WE_SP1, WE_M
	} = 0;
	

		#10 reset = 1'b1;
	end


	initial begin
		#34;
		fetch();
		fetch();
		fetch();
		fetch();
		fetch();
		fetch();
		fetch();
		fetch();
		fetch();
		fetch();
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
//	initial begin
//		$monitor("Time = %0t /t  = %b",$time, clk_div.div_ratio);
//	end

endmodule
