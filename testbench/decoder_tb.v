`include "includes.vh"

module decoder_tb();
	reg [7:0] select;
	reg EN;

	decoder #(.WIDTH(3)) my_decoder(.S(select), .D(), .EN(EN));

	initial begin
		$dumpfile("decoder_tb.vcd");
		$dumpvars(0,decoder_tb);
		$printtimescale;

		$monitor("Time = %0t \tEN = %b| select = %0h, decode = %b",$time,EN, select, my_decoder.D);
	end

	initial begin
		for(select = 0; select < 7; select = select + 1) begin
			#5 EN = 0;
			#5 EN = 1;
		end

		#10 $finish();
	end

endmodule
