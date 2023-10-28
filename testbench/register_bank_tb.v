`include "includes.vh"

module register_bank_tb();
	reg clk, reset;
	wire clk_out;

	reg [2:0] address;
	reg CS, RD_WR;

	reg [`DATA_WIDTH - 1:0] rdata, wdata;
	wire [`DATA_WIDTH - 1:0] data_bus;
	
	reg [`DATA_WIDTH - 1:0] wdata_array[0:2];


	parameter clk_period = 10;
	integer i;

	always #(clk_period/2) clk = ~clk;

	//instantiate DUT
	register_bank #(.NUM_REG(8)) reg_bank(.clk(clk),.reset(reset), .address(address), .data(data_bus), .RD_WR(RD_WR), .CS(CS));

	assign data_bus = wdata;

	initial begin
		$dumpfile("register_bank_tb.vcd");
		$dumpvars(0,register_bank_tb);
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
		
		for(i = 0; i < 8; i++) begin
			wdata_array[i] = $urandom;
			do_write(i, wdata_array[i]);
			$display("do_write at Addr %h, wdata =%h", i, wdata_array[i]);
		end
		for(i = 0; i < 8; i++) begin
			do_read(i);
			if(rdata == wdata_array[i])
				$display("PASS : data match at Addr %h, rdata = %h, wdata =%h", i, rdata, wdata_array[i]);
			else
				$display("FAIL : data match at Addr %h, rdata = %h, wdata =%h", i, rdata, wdata_array[i]);
		end
		
		$finish();
	end

	task do_write(input [2:0] addr, input [`DATA_WIDTH -1:0] w_data);
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
	task do_read(input [2:0] addr);
		begin
			CS <=1;
			RD_WR <=1;
			address <= addr;
			@(posedge clk);
			rdata <= data_bus;
			CS <=0;
		end
	endtask
endmodule
