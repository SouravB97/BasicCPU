module counter
#(parameter DATA_WIDTH = `DATA_WIDTH)(
	input clk, reset,
	input CS, WE, OE, CNT_EN,
	inout [DATA_WIDTH-1:0] data
);

	wire [DATA_WIDTH-1:0] J,K,Q,D;
	wire [DATA_WIDTH:0] cnt_en;
	wire carry; //output?

	assign cnt_en[0] = CNT_EN;
	assign carry = cnt_en[DATA_WIDTH];

	genvar i;
	generate
		for(i = 0; i < DATA_WIDTH; i=i+1) begin
			//muxes
			mux mux0(.D({D[i], cnt_en[i]}), .S(WE), .Y(J[i]));
			mux mux1(.D({~D[i], cnt_en[i]}), .S(WE), .Y(K[i]));

			//JK flip flop
			jk_ff jk_ff0 (.clk(clk), .reset(reset),
				.J(J[i]), .K(K[i]), .Q(Q[i])); 

			//tri state buffer and latch
			tranif1(Q[i], data[i], OE & CS);
			latch latch0 (.D(data[i]), .Q(D[i]), .EN(WE & CS));

			assign cnt_en[i+1] = cnt_en[i] & Q[i];
		end
	endgenerate


endmodule
