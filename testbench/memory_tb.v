`include "includes.v"

module memory_tb();
	reg clk, reset;
	wire clk_out;

	reg [addr_width - 1:0] address;
	reg CS, RD_WR;

	reg [`DATA_WIDTH - 1:0] rdata, wdata;
	wire [`DATA_WIDTH - 1:0] data_bus;
	
	reg [`DATA_WIDTH - 1:0] wdata_array[depth-1 :0];


	parameter clk_period = 10;
	reg [31:0] i;
	parameter depth = 8;
	parameter addr_width = $clog2(depth);

	always #(clk_period/2) clk = ~clk;

	//instantiate DUT
	memory #(.DEPTH(depth)) ram(.clk(clk), .address(address), .data(data_bus), .RD_WR(RD_WR), .CS(CS));

	assign data_bus = wdata;

	initial begin
		$dumpfile("memory_tb.vcd");
		$dumpvars(0,memory_tb);
		$timeformat(-9, 2, " ns", 20);

		clk <=0;
		reset <=0;
		wdata <= 'bz;
		$printtimescale;

		#13 reset = 1'b1;
	end


	initial begin
		@(posedge reset);
		#10;
		//ram.print_mem();
		
		for(i = 0; i < depth; i++) begin
			wdata_array[i] = $urandom;
			do_write(i, wdata_array[i]);
			$display("do_write at Addr %h, wdata =%h", i, wdata_array[i]);
		end
		for(i = 0; i < depth; i++) begin
			do_read(i);
			if(rdata == wdata_array[i])
				$display("PASS : data match at Addr %h, rdata = %h, wdata =%h", i, rdata, wdata_array[i]);
			else
				$display("FAIL : data mismatch at Addr %h, rdata = %h, wdata =%h", i, rdata, wdata_array[i]);
		end
		
		ram.print_mem();

		do_write('h3, 'hDE);
		#25;
		do_write('h4, 'h45);
		#36;
		do_read('h3);
			if(rdata == 'hDE)
				$display("PASS : data match at Addr %h, rdata = %h, wdata =%h", 'h3, rdata, 'hDE);
			else
				$display("FAIL : data mismatch at Addr %h, rdata = %h, wdata =%h", 'h3, rdata, 'hDE);
		

		$finish();
	end

	task do_write(input [addr_width -1:0] addr, input [`DATA_WIDTH -1:0] w_data);
		begin
			CS <= 1;
			RD_WR <= 0;
			address <= addr;
			wdata <= w_data;
			@(posedge clk);
			CS <= 0;
			wdata <= 'bz;
		end
	endtask

	//task do_read(output[`DATA_WIDTH -1:0] rdata_in);
	task do_read(input [addr_width - 1:0] addr);
		begin
			CS <=1;
			RD_WR <=1;
			address <= addr;
			@(posedge clk);
			//#(clk_period/1000);
			#1;
			rdata = data_bus;
			CS =0;
			#1;
			//#(clk_period/1000);
		end
	endtask

endmodule
