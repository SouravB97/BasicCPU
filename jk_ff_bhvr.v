
module jk_ff(clk, reset, J, K, Q, Q_bar);
	input clk, reset;
	input J,K;
	output reg Q;
	output Q_bar;

	assign Q_bar = ~Q;

	always @(reset) begin
		if(!reset)
			Q <= 0;
	end

	always @(posedge clk) begin
			case({J,K})
				2'b00: ;			//no change
				2'b01: Q =/* #0.01*/ 1'b0;	//reset
				2'b10: Q =/* #0.01*/ 1'b1;	//set
				2'b11: Q =/* #0.01*/ ~Q; //toggle
			endcase
	end

endmodule
