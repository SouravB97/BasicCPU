module jk_ff(clk, reset,J, K, Q, Q_bar);
	input clk, reset;
	input J,K;
	output Q_bar;
	output reg Q;

	assign Q_bar = ~Q;

	always @(reset)
		if(!reset)	
			Q <=0;

	always @(posedge clk) begin
		if(!reset)
			Q <= 0;
		else begin
			case({J,K})
				2'b00: ; //no change
				2'b01:	Q <= 0;
				2'b10:	Q <= 1;
				2'b11:  Q <= ~Q;
			endcase
		end
	end

endmodule
