`include "includes.vh"

module mux_tb();
	reg[7:0] data;
	reg[2:0] sel;
	wire y, y1;

	reg[15:0] data0 = 'h0110;
	reg[15:0] data1 = 'h0220;
	reg[15:0] data2 = 'h0330;
	reg[15:0] data3 = 'h0440;
	reg[15:0] data4 = 'h0550;
	reg[15:0] data5 = 'h0660;
	reg[15:0] data6 = 'h0770;
	reg[15:0] data7 = 'h0108;
	wire[15:0] data_out;

	mux #(.DATA_WIDTH(8)) eight_mux(.D(data),.S(sel),.Y(y));
	mux #(.DATA_WIDTH(2)) two_mux(.D(data[1:0]),.S(sel),.Y(y1));
	//switch #(.SIZE(4)) switch0(.data_in({data3, data2, data1, data0}), .S(sel), .data_out(data_out));
	switch #(.SIZE(8), .DATA_WIDTH(16)) switch0(
		.data_in({data7, data6, data5, data4, data3, data2, data1, data0}),
		.S(sel), .data_out(data_out));

	initial begin
		$dumpfile("mux_tb.vcd");
		$dumpvars(0,mux_tb);
		$printtimescale;

		$monitor("Time = %0t \t data = %b, sel = %b, y = %b",$time, data, sel, y1);
		$monitor("Time = %0t \t data = %h, sel = %h",$time, data_out, sel);
	end

	initial begin
		for(sel = 0; sel < 7; sel = sel + 1) begin
			data = 1 << sel;
			#10;
		end
		#10;
		for(sel = 0; sel < 7; sel = sel + 1) begin
			data = 1 << sel;
			#10;
		end

		#10 $finish();
	end

endmodule
