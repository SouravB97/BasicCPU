`include "includes.v"

module register_tb();
	reg clk, reset;
	reg [`DATA_WIDTH-1:0] data, rdata;
	wire [`DATA_WIDTH-1:0] data_bus = 'bz;
	reg CS, OE, WE, OE_A;

	parameter clk_period = 10;
	integer i;

	always #(clk_period/2) clk = ~clk;

	initial begin
		$dumpfile("register_tb.vcd");
		$dumpvars(0,register_tb);
		$timeformat(-9, 2, " ns", 20);
		$printtimescale;

		clk=0;
		reset=0;
		CS=0;OE=0;WE=0;OE_A=0;

		$monitor("Time=%0t\t data = %h, rdata = %h, CS=%b,WE=%b,OE=%b", $time, data, rdata, CS, WE, OE);

		#10 reset = 1'b1;
	end

//	ac_register reg1(
//		.clk(clk), .reset(reset),
//		.data(data_bus),
//		.CS(CS),.WE(WE),.OE(OE)//, .CNT_EN(1)
//	);
	ar_register reg1(
		.clk(clk), .reset(reset),
		.data(data_bus),
		.CS(CS),.OE_A(OE_A),
		.WE_H(WE),.OE_H(OE),
		.WE_L(WE),.OE_L(OE)
	);
	assign data_bus = data;

	task do_write(input [`DATA_WIDTH -1:0] wdata);
		begin
			CS <= 1;
			WE <= 1;
			data <= wdata;
			@(posedge clk);
			CS <= 0;
			WE <= 0;
			data <= 'bz;
		end
	endtask

	task do_read();
		begin
			CS <= 1;
			OE <= 1;
			@(posedge clk);
			rdata <= data_bus;
			OE <= 0;
			CS <= 0;
		end
	endtask

	initial begin
		#20;

		#20 do_write('hBF);
		#15 do_write('hAD);
//		#10 do_read();
//		#5  do_read();
		#15 do_write('hFF);
//		#0  do_read();
		#15 do_write('h67);
//		#5  do_read();
		#15 do_write('h23);
//		#5  do_read();
		#15 do_write('h16);
//		#5  do_read();
		#15 do_write('hD3);
//		#5  do_read();


		#10;
		CS=1; WE=1; OE=1;
		#50 $finish();
	end
	always #(17) OE_A = ~OE_A;





endmodule
