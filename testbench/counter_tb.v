`include "includes.vh"

module counter_tb();
	reg clk, reset;
	reg [`DATA_WIDTH - 1:0] data = 'bz;
	reg [`DATA_WIDTH - 1:0] rdata;
	wire [`DATA_WIDTH -1:0] data_bus = 'bz;
	reg OE, CS, EN, CNT_EN;

	parameter clk_period = 10;
	integer i;

	always #(clk_period/2) clk = ~clk;

	initial begin
		$dumpfile("counter_tb.vcd");
		$dumpvars(0,counter_tb);
		$timeformat(-9, 2, " ns", 20);
		$printtimescale;

		clk 	= 0;
		reset = 0;
		CS =0; EN=0; OE=0; CNT_EN=0;
		rdata = 0;

		#5 reset = 1'b1;
	end

	counter counter1(
		.clk(clk), .reset(reset),
		.data(data_bus),
		.OE(OE), .EN(EN), .CS(CS), .CNT_EN(CNT_EN)
	);

	assign data_bus = data;

	initial begin
		//register test
		#20;
		#20		do_write('hBF);
		#15		do_write('hAD);
		#10		do_read();
		#5		do_read();
		#15		do_write('hFF);
		#0		do_read();
		#15		do_write('h67);
		#0		do_read();
		
		//counter test
		#20;
		CNT_EN = 1;
		CS = 1;
		OE =1;
		for(i =0; i < 200; i++) begin
			#15;
		end

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
