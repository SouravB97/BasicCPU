

module register_bank
	#(parameter NUM_REG =8,
		parameter ADDR_WIDTH = $clog2(`DATA_WIDTH))(
	input clk, reset,
	input CS, RD_WR,
	input [ADDR_WIDTH -1:0] address,
	inout [`DATA_WIDTH -1:0] data
);

	reg [`DATA_WIDTH -1 :0] bank[NUM_REG -1 :0];
	reg EN;
	integer i;

	always @(reset) begin
		if(!reset) begin
			EN = 0;
			for(i  =0; i < NUM_REG -1; i++)
				bank[i] <= 'h0;
		end
	end

	assign data = EN ? bank[address] : 'bz;

	always @(posedge clk) begin
		if(CS) begin
			if(RD_WR) begin 	//READ
				//data = bank[address];
				EN = 1;
			end
			else begin 	//WRITE
				EN = 0;
				bank[address] = data;
			end
		end
		else begin
			EN = 0;
		end
	end

endmodule

