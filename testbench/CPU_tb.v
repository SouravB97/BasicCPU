`include "includes.vh"

module CPU_tb();

	localparam mem_input	= "../asm_programmes/compiled_hex/bootcode.hex";
	localparam mem_output	= "../dump/output.hex";
	localparam dump_file 	= "../dump/CPU_tb.vcd";

	reg clk, reset, hlt;

	localparam clk_period = 2;	//ns
	localparam bootdelay = 3*clk_period + 2; //time after which to raise reset
	localparam max_cycles = 200; //max cycles after reset assertion to kill test
	localparam drain_cycles = 10; //additional cycles after hlt for check, report phase

	integer cycle = 0;	//current cycle
	integer i;

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
	cpu_m cpu(.clk(clk), .reset(reset), .hlt(hlt));
	
	//TB signals
	reg [7:0] rdata;
	reg [7:0] wdata = 'h25;
	reg [15:0] addr;
	reg [`DATA_WIDTH - 1 :0] mem [0:`MEMORY_DEPTH -1] ;

	initial begin
		$dumpfile(dump_file);
		$dumpvars(0,CPU_tb);
		$timeformat(-9, 2, " ns", 20);
		$printtimescale;

		//load memory
		$readmemh(mem_input, mem); //must be same folder as tb top, where irun is run
		$readmemh(mem_input, cpu.RAM.mem); //must be same folder as tb top, where irun is run
		init();
	end

	//start clk
	always #(clk_period/2) clk = ~clk;

//Sequences
	initial begin : main_seq
		@(posedge reset);
		$display("%d Starting seqs at time %t",cycle, $time);
		repeat(max_cycles) @(posedge clk);
		$display("%d Reached max_cycles %d. Exiting test", cycle, $time, max_cycles);
		exit();
	end
	initial begin : wait_for_hlt
		@(posedge reset);
		@(posedge (hlt | cpu.control_unit.HLT));
		$display("%d CPU hlt detected at %t. Exiting test",cycle, $time);
		repeat(drain_cycles) @(posedge clk);
		exit();
	end
	always begin : inc_cycle
		@(posedge clk) cycle += 1;
		//$display("%t cycle = %d",$time, cycle);
	end

	task init();
		begin
		clk <=0;
		reset <=0;
		hlt <= 0;
		#bootdelay reset = 1'b1;
		//repeat(10) @(posedge clk);
		//hlt = 1;
		//reset = 0;
		//#(bootdelay) reset = 1'b1;
		end
	endtask
	task exit();
		begin
		$display("%d Ending seqs at time %t",cycle, $time);
		$writememh(mem_output, cpu.RAM.mem);
		$finish();
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
			force cpu.OE_M = 1;
			//MID <= 'h4 ; 
			//MID_EN <= 1;
			@(negedge clk); //T1
			rdata <= cpu.data_bus ;
			@(negedge clk); //T2
			release cpu.address_bus ;
			release cpu.OE_M ;
			//MID_EN <= 0;
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
			force cpu.WE_M = 1;
			//SID <= 'h4;
			//SID_EN <= 1;
			@(negedge clk); //T1
			release cpu.address_bus ;
			release cpu.data_bus ;
			release cpu.WE_M ;
			//SID_EN <= 0;
		end
	endtask

	task memory_sweep_check();
		reg [15:0] addr, i;
		reg [7:0] expected_rdata, actual_rdata, wdata;
		begin
			//pause CPU:
			force cpu.control_unit.en_timer_decoder = 0;
			//WRITE
			addr = 16'h0000;
			for(i = 0 ; i < `MEMORY_DEPTH; i++) begin
				wdata = 255 - i;//mem[i];
				wr_mem(addr, wdata);
				addr++;
			end
			//READ
			addr = 16'h0000;
			for(i = 0 ; i < `MEMORY_DEPTH; i++) begin
				expected_rdata = 255-i;//mem[i];
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
