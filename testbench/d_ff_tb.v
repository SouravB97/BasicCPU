`include "includes.v"

module d_ff_tb();
	reg clk, reset, D, J, K;
	wire Q;

	parameter clk_period = 10;

	always #(clk_period/2) clk = ~clk;

	d_ff dff(.clk(clk),
					 .reset(reset),
					 .D(D),
					 .Q(Q));

	jk_ff jkff(.clk(clk), .reset(reset), .J(J), .K(K), .Q(q), .Q_bar(q_bar));

	initial begin
		$dumpfile("d_ff_tb.vcd");
		$dumpvars(0,d_ff_tb);
		$printtimescale;

		clk <= 0;
		reset <= 1;
		D <= 0;
		J <= 0;
		K <= 0;

		#500 $finish();
	end

	always #(6) D = ~D;
	always #(134) reset = ~reset;

	initial begin
		for(integer i = 0; i < 32; i=i+1) begin
			#7 {J,K} = i[1:0];
			$display("%b,%b|%b,%b", J, K, jkff.Q, jkff.Q_bar);
		end
	end

endmodule
