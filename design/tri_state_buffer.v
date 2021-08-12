module tri_state_buffer
#(parameter DATA_WIDTH = `DATA_WIDTH)(
	input  OE,
	inout [DATA_WIDTH-1:0] data_in,
	inout [DATA_WIDTH-1:0] data_out
);

	genvar i;
	generate
	  for(i=0; i < DATA_WIDTH; i=i+1) begin
	    tranif1(data_in[i], data_out[i], OE);
	  end
	endgenerate

endmodule
