`include "includes.v"

module mux_tb();
	reg[32:0] data;
	reg[7:0] sel;
	wire y, y1;
	
	mux eight_mux(.D(data), .S(sel), .Y(y));
	mux #(.DATA_WIDTH(2)) two_mux(.D(data), .S(sel), .Y(y1));
	mux #(.DATA_WIDTH(32)) thirtytwo_mux(.D(data), .S(sel));

	initial begin
		$dumpfile("mux_tb.vcd");
		$dumpvars(0, mux_tb);

		$monitor("Time = %0t\t data = %b, sel = %b, y = %b", $time, data, sel, y);
	end

	initial begin
	for(sel = 0; sel < 7; sel = sel +1) begin
		data = 1 << sel;
		#10;
	end
	#10;
	for(sel = 0; sel < 129; sel = sel +1) begin
		data = 1 << sel;
		#10;
	end

	$finish();
	end

endmodule
