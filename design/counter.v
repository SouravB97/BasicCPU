module counter
#(parameter DATA_WIDTH = `DATA_WIDTH)(
	input clk, reset,
	input CS, WE, OE, CNT_EN,
	inout [DATA_WIDTH-1:0] data,
	output [DATA_WIDTH-1:0] data_out,
	output carry
);

	wire [DATA_WIDTH-1:0] J,K,Q,D;
	wire [DATA_WIDTH:0] cnt_en;
	//wire carry; //output?
	assign data_out = Q;

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

//Programme counter register
//A special 16 bit register which is basically the address register 
//with CNT_EN input
module pc_register
#(parameter ADDR_WIDTH = 2*`DATA_WIDTH,
  parameter DATA_WIDTH = ADDR_WIDTH/2)(
	input clk, reset,
	input CS, OE_A, CNT_EN,
	input WE_L, OE_L, WE_H, OE_H,
	inout [DATA_WIDTH-1:0] data,
	output [ADDR_WIDTH-1:0] address,
	output carry
);
	wire [DATA_WIDTH-1:0] addr_l, addr_h;

	counter #(.DATA_WIDTH(DATA_WIDTH)) reg_l (
		.clk(clk), .reset(reset),
		.data(data), .data_out(addr_l),
		.CS(CS),.WE(WE_L),.OE(OE_L),
		.CNT_EN(CNT_EN), .carry(carry_out)
	);

	counter #(.DATA_WIDTH(DATA_WIDTH)) reg_h (
		.clk(clk), .reset(reset),
		.data(data), .data_out(addr_h),
		.CS(CS),.WE(WE_H),.OE(OE_H),
		.CNT_EN(carry_out), .carry(carry)
	);

	tri_state_buffer #(.DATA_WIDTH(2*DATA_WIDTH)) tsb(
		.data_in({addr_h, addr_l}),
		.data_out(address),
		.OE(OE_A)
	);


endmodule


