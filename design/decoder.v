
//WIDTH is width of select input of decoder
module decoder
	#(parameter WIDTH = 3)(
	input  [WIDTH -1 :0] S,
	input EN,
	output [(2 ** WIDTH) -1 : 0] D
);
	wire [(2** WIDTH) -1 : 0] mux_out;
	wire [(2** WIDTH) -1 : 0] const_1 = 1;

	genvar i;
	generate
		for(i = 0; i < 2** WIDTH; i = i+1) begin
			mux #(.DATA_WIDTH(2** WIDTH)) mux_m(.D(const_1<<i),.S(S),.Y(mux_out[i]));
			assign #(0.1,0.1) D[i] = mux_out[i] & EN;
		end
	endgenerate

endmodule
