`include "includes.vh"

module d_ff_tb();
	reg clk, reset, D, J, K;
	wire Q, Q1, Q_bar;

	parameter clk_period = 10;
	integer i;

	d_ff dff(.clk(clk),
					 .reset(reset),
					 .D(D),
					 .Q(Q));

	jk_ff jkff(.clk(clk),.reset(reset),.J(J),.K(K),.Q(Q1),.Q_bar(Q_bar));

	initial begin
		$dumpfile("d_ff_tb.vcd");
		$dumpvars(0,d_ff_tb);
		$printtimescale;

		clk <=0;
		reset <=0;
		D <= 0;
		J <= 0;
		K <= 0;
	end

	initial begin
		forever
			#(clk_period/2) clk = ~clk;
	end

	always #(clk_period*3.87) D = ~D;
	always #(clk_period*16.29) reset = ~reset;

	initial begin
		//for (i = 0; i < 10; i++) begin;
		//	#((i%3)*5) D <= ~D;
		//end
		#1000		$finish();
	end

	initial begin
		for(integer i = 0; i < 32; i = i+1) begin
			#7 {J,K} = i[1:0];
			$display("i = %d\t {J,K,Q,Q1} = {%b,%b,%b,%b}",i,J,K,Q1,Q_bar);
		end
	end

//	initial begin
//		$monitor("Time = %0t \t reset = %b \t D = %b\t Q = %b",$time, reset, D, Q);
//	end

//	always@(D) begin
//		$display("Time = %0t \t D = %b\t Q = %b",$time, D, Q);
//	end

endmodule
