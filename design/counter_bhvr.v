//`include "timescale.v"
//`define DATA_WIDTH 8

module counter
#(parameter DATA_WIDTH = `DATA_WIDTH)(
	input clk, reset,
	input OE, CS, EN, CNT_EN,
	inout [DATA_WIDTH - 1:0] data
);

	reg [DATA_WIDTH -1:0] data_int = 00; //reset value

	always @(reset) begin
 		if(!reset)	begin
			data_int = 'b0;  //clear assign data
		end
	end

	assign data  = CS ? (OE ? data_int : 'bz) : 'bz;

	always @(posedge clk) begin
		if(!reset)
			data_int = 0;
		else begin
			if(CS) begin
				case({EN, OE})
					2'b00 :;
					2'b01 :;
					2'b10 : data_int = data;
					2'b11	:	$display("ERROR from module counter: EN and OE are 1 at the same time");
				endcase
				if(CNT_EN)
					data_int = data_int + 1;
			end
		end
	end

endmodule
