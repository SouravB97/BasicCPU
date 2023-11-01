module counter
#(parameter DATA_WIDTH = `DATA_WIDTH)(
	input clk, reset,
	input CS, WE, OE, CNT_EN, SYNC_CLR,
	inout [DATA_WIDTH-1:0] data
);

	reg [DATA_WIDTH-1:0] data_int = 0;

	always @(reset)
		if(!reset)
			data_int = 0;

	assign data = CS ? (OE ? data_int : 'bz) : 'bz;

	always @(posedge clk) begin
		if(~reset | SYNC_CLR)
			data_int = 0;
		else begin
			if(CS) begin
				case({WE,OE})
					2'b00 :; //no change
					2'b01 :; //READ
					2'b10 : data_int = data;	//WRITE
					2'b11 : $display("ERROR from module counter: OE and WE are 1 at the same time!!");	//INVALID
				endcase
				if(CNT_EN)
					data_int = data_int + 1;
			end
		end
	end

endmodule
