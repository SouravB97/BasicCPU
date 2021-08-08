`include "includes.v"

module register_tb();
	reg clk, reset;
	reg [`DATA_WIDTH - 1:0] data;
	reg [`DATA_WIDTH - 1:0] rdata;
	wire [`DATA_WIDTH -1:0] data_bus = 'bz;
	reg OE, CS, EN;

	parameter clk_period = 10;
	integer i;

	always #(clk_period/2) clk = ~clk;

	initial begin
		$dumpfile("register_tb.vcd");
		$dumpvars(0,register_tb);
		$timeformat(-9, 2, " ns", 20);
		$printtimescale;

		clk 	= 0;
		reset = 0;
		CS =0; EN=0; OE=0;
		rdata = 0;

		#10 reset = 1'b1;
	end

	counter reg1(
		.clk(clk), .reset(reset),
		.data(data_bus),
		.OE(OE), .EN(EN), .CS(CS), .CNT_EN(1)
	);

	assign data_bus = data;

	initial begin
		#20;
		#20 	do_write('hBF);
		#15 	do_write('hAD);
		#10 	do_read();
		#5   	do_read();
		#15 	do_write('hFF);
		#0   	do_read();
		#15 	do_write('h67);
		#5   	do_read();
		#15 	do_write('h23);
		#5   	do_read();
		#15 	do_write('h16);
		#5   	do_read();
		#15 	do_write('hD3);
		#5   	do_read();

		#10;
		CS =1;EN =1; OE=1;
		#50		$finish();
	end

	initial begin
		$monitor("Time = %0t\tdata = %h, rdata = %h, OE=%b, EN=%b, CS=%b",$time, data, rdata,OE,EN,CS);
	end


	task do_write(input [`DATA_WIDTH -1:0] wdata);
		begin
			CS <= 1;
			EN <= 1;
			data <= wdata;
			@(posedge clk);
			CS <= 0;
			EN <= 0;
			data <= 'bz;
		end
	endtask

	//task do_read(output[`DATA_WIDTH -1:0] rdata_in);
	task do_read();
		begin
			CS <=1;
			OE <=1;
			@(posedge clk);
			//rdata_in <= data_bus;
			rdata <= data_bus;
			OE <=0;
			CS <=0;
		end
	endtask

endmodule
