
module bus
	#(parameter WIDTH = 3)(
	input [WIDTH -1 :0] select,
	input EN,
	inout [`DATA_WIDTH -1 :0] data
);
	
	wire [`DATA_WIDTH -1 :0] reg_in;
	wire [2 ** WIDTH -1 :0] decode;

	genvar i;
	generate
		for(i = 0; i< `DATA_WIDTH; i = i+1) begin

			decoder #(.WIDTH(WIDTH)) out_decoder(
				.S(select), .EN(EN),
				.D(decode)
			)
			genvar j;
			generate
				for(j = 0; j< 2 ** WIDTH; j = j+1) begin
					tranif1(reg_in[i], data[i], decode[j]);
				end
			endgenerate


			decoder #(.WIDTH(WIDTH)) in_decoder(
				.S(select), 
		end
	endgenerate
endmodule
