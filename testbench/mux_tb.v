`include "includes.vh"

module mux_tb();
	reg[7:0] data;
	reg[2:0] sel;
	wire y, y1;

	mux #(.DATA_WIDTH(8)) eight_mux(.D(data),.S(sel),.Y(y));
	mux #(.DATA_WIDTH(2)) two_mux(.D(data),.S(sel),.Y(y1));

	initial begin
		$dumpfile("mux_tb.vcd");
		$dumpvars(0,mux_tb);
		$printtimescale;

		$monitor("Time = %0t \t data = %b, sel = %b, y = %b",$time, data, sel, y1);
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
