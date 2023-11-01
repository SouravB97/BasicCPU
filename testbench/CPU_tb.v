`include "includes.vh"

module CPU_tb();
	reg clk, reset;
	wire clk_out;

	localparam clk_period = 10;
	localparam bootdelay = 11;
	integer i;

	always #(clk_period/2) clk = ~clk;

	//========================= CONTROL UNIT OUTPUTS =====================================
	wire[32:0] control_bus;
	//control bus inputs
	reg [4:0] ALU_OPCODE;
	reg [4:0] MID, SID; //data bus master/slave ID
	reg [1:0] AMID; //address master ID
	reg PC_INR, MID_EN, SID_EN;

	//control bus
	assign control_bus = {
		ALU_OPCODE, MID, SID, AMID,
		PC_INR, MID_EN, SID_EN
	};

	//================instantiate DUT==========================
	CPU cpu(.clk(clk), .reset(reset) /*,.control_bus(control_bus)*/);
	
	//TB signals
	reg [7:0] rdata;
	reg [7:0] wdata = 'h25;
	reg [15:0] addr;
	reg [`DATA_WIDTH - 1 :0] mem [0:`MEMORY_DEPTH -1] ;

	initial begin
		$dumpfile("../dump/CPU_tb.vcd");
		$dumpvars(0,CPU_tb);
		$timeformat(-9, 2, " ns", 20);
		//load memory
		$readmemh("bootcode.hex", mem); //must be same folder as tb top, where irun is run
		$readmemh("bootcode.hex", cpu.RAM.mem); //must be same folder as tb top, where irun is run

		$display("HLT DECIR0 = %d", `DEC_OP(`CPU_INSTR_HLT));
		$display("NOP DECIR0 = %d", `DEC_OP(`CPU_INSTR_NOP));
		$display("ADD DECIR0 = %d", `DEC_OP(`CPU_INSTR_ADD));

		clk <=0;
		reset <=0;
		$printtimescale;

		#bootdelay reset = 1'b1;
		repeat(50) @(posedge clk);
		reset = 0;
		#(bootdelay+clk_period/2) reset = 1'b1;

		$writememh("output.hex", cpu.RAM.mem);
	end


//Sequences
	initial begin
		@(posedge reset); repeat(2) #clk_period;
		$display("Starting seqs at time %t", $time);
		//memory_sweep_check();
		//mem_test1();
		repeat(100) @(posedge clk);
		$display("Ending seqs at time %t", $time);
		$finish();
	end

//	initial begin
//		$monitor("Time = %0t /t  = %b",$time, clk_div.div_ratio);
//	end
	task fetch();
		begin
			//@(negedge clk); //T0
			AMID <= 0;
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
			//OE_PC <= 0;
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

	task rd_mem (input [15:0] address, output [7:0] rdata);
		begin
			if(address[15]) begin
				$display("rd_mem: Invalid address; not within memory map range. Addr: %0h", address);
				//$finish();
			end
			//@(negedge clk); //T0
			force cpu.address_bus = address;
			//force cpu.OE_M = 1;
			MID <= 'h4 ; 
			MID_EN <= 1;
			@(negedge clk); //T1
			rdata <= cpu.data_bus ;
			@(negedge clk); //T2
			release cpu.address_bus ;
			//release cpu.OE_M ;
			MID_EN <= 0;
		end
	endtask
	task wr_mem (input [15:0] address, input [7:0] wdata);
		begin
			if(address[15]) begin
				$display("wr_mem: Invalid address; not within memory map range. Addr: %0h", address);
				//$finish();
			end
			//@(negedge clk); //T0
			force cpu.address_bus = address;
			force cpu.data_bus = wdata;
			//force cpu.WE_M = 1;
			SID <= 'h4;
			SID_EN <= 1;
			@(negedge clk); //T1
			release cpu.address_bus ;
			release cpu.data_bus ;
			//release cpu.WE_M ;
			SID_EN <= 0;
		end
	endtask

	task memory_sweep_check();
		reg [15:0] addr, i;
		reg [7:0] expected_rdata, actual_rdata;
		begin
			addr = 16'h8000;
			for(i = 0 ; i < `MEMORY_DEPTH; i++) begin
				expected_rdata = mem[i];
				rd_mem(addr, actual_rdata);
				if(expected_rdata == actual_rdata) begin
					$display("MEM_CHECK: %0d) Data match for addr %0h, Actual = %0h, Expected = %0h",i, addr, actual_rdata, expected_rdata);
				end else begin
					$display("MEM_CHECK: %0d) Data mismatch for addr %0h, Actual = %0h, Expected = %0h",i, addr, actual_rdata, expected_rdata);
				end
				addr++;
			end
		end
	endtask

	task mem_test1();
	begin
		$display("At init, rdata = %0h", rdata);
		addr = 16'h8000; rd_mem(addr, rdata); 	$display("addr = %h, rdata = %h", addr, rdata);
		addr = 16'h8002; rd_mem(addr, rdata); 	$display("addr = %h, rdata = %h", addr, rdata);
		addr = 16'h8002; wr_mem(addr, 8'h25);	$display("Writing addr = %h, wdata = %h", addr, 'h25);
		addr = 16'h8002; rd_mem(addr, rdata); 	$display("addr = %h, rdata = %h", addr, rdata);
		addr = 16'h8000; wr_mem(addr, 8'h8F);	$display("Writing addr = %h, wdata = %h", addr, 'h8F);
		addr = 16'h8000; rd_mem(addr, rdata); 	$display("addr = %h, rdata = %h", addr, rdata);
		addr = 16'h0000; rd_mem(addr, rdata); 	$display("addr = %h, rdata = %h", addr, rdata);
	end
	endtask

endmodule
