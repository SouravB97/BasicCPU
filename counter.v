//`include "timescale.v"
//`define DATA_WIDTH 8
//`include "d_ff.v"

module counter
#(parameter DATA_WIDTH = `DATA_WIDTH)(
	input clk, reset,
	input OE, CS, EN, CNT_EN,
	inout [DATA_WIDTH - 1:0] data
);

	wire [DATA_WIDTH -1:0] j,k,q,d1;
	wire [DATA_WIDTH :0] cnt_en;
	wire carry;

	assign cnt_en[0] = CNT_EN;
	assign carry = cnt_en[DATA_WIDTH];

	//BIT 0 instance
	genvar i;
	
	generate
		for(i = 0; i< DATA_WIDTH; i = i+1) begin
			mux #(.DATA_WIDTH(2)) mux_0(.D({d1[i],cnt_en[i]}),  .S(EN), .Y(j[i]));
			mux #(.DATA_WIDTH(2)) mux_1(.D({~d1[i],cnt_en[i]}), .S(EN), .Y(k[i]));

			jk_ff jkff_0(.clk(clk),.reset(reset),.J(j[i]),.K(k[i]),.Q(q[i]),.Q_bar());

			tranif1(q[i], data[i], OE & CS);
			//tranif1(data[i], d1[i], EN);
			latch l1(.D(data[i]), .Q(d1[i]), .EN(EN & CS));

			assign cnt_en[i+1] = cnt_en[i] & q[i];
		end
	endgenerate

//single inst
//			mux #(.DATA_WIDTH(2)) mux_0(.D({d1[0],cnt_en[0]}),  .S(EN), .Y(j[0]));
//			mux #(.DATA_WIDTH(2)) mux_1(.D({~d1[0],cnt_en[0]}), .S(EN), .Y(k[0]));
//
//			jk_ff jkff_0(.clk(clk),.reset(reset),.J(j[0]),.K(k[0]),.Q(q[0]),.Q_bar());
//
//			tranif1(q[0], data[0], OE);
//			tranif1(data[0], d1[0], EN);
//
//			assign cnt_en[0+1] = cnt_en[0] & q[0];

endmodule
