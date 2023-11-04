`include "includes.vh"

module CPU_tb();

	localparam mem_input	= "./micro_codes/bootcode.hex";
	localparam mem_output	= "../dump/output.hex";
	localparam dump_file 	= "../dump/CPU_tb.vcd";

	reg clk, reset;
	wire clk_out;

	localparam clk_period = 10;
	localparam bootdelay = 13;
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
		$dumpfile(dump_file);
		$dumpvars(0,CPU_tb);
		$timeformat(-9, 2, " ns", 20);
		//load memory
		$readmemh(mem_input, mem); //must be same folder as tb top, where irun is run
		$readmemh(mem_input, cpu.RAM.mem); //must be same folder as tb top, where irun is run

		clk <=0;
		reset <=0;
		$printtimescale;

		#bootdelay reset = 1'b1;
		//repeat(1000) @(posedge clk);
		//reset = 0;
		//#(bootdelay+clk_period/2) reset = 1'b1;
	end


//Sequences
	initial begin
		@(posedge reset);
		$display("Starting seqs at time %t", $time);
		//memory_sweep_check();
		//mem_test1();
	//	for(integer i=0; i< 50 | (cpu.HLT != 0); i++) begin
	//		@(posedge clk);
	//	end
		repeat(50) @(posedge clk);
		
		exit();
	end

	task exit();
		begin
		$display("Ending seqs at time %t", $time);
		$writememh(mem_output, cpu.RAM.mem);
		$finish();
		end
	endtask

//	initial begin
//		$monitor("Time = %0t /t  = %b",$time, clk_div.div_ratio);
//	end

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
			force cpu.en_timer_decoder = 0;
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
