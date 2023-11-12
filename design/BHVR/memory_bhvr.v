
module memory
 #(parameter DEPTH = 256,
 	 parameter ID = 0,
 	 parameter DATA_WIDTH = `DATA_WIDTH,
	 parameter ADDR_WIDTH = $clog2(DEPTH))(

	 input [ADDR_WIDTH - 1 :0] address,
	 inout [DATA_WIDTH - 1 :0] data,
	 input CS, OE, WE,
	 input clk, reset
);
	reg [DATA_WIDTH - 1 :0] mem [0: DEPTH-1] ;
	//reg [DATA_WIDTH - 1 :0] mem [DEPTH-1 :0] ;
	wire output_condition;
	reg [DATA_WIDTH - 1 :0] rdata;
	integer i;

	assign output_condition = reset & CS & OE;
	assign /*#(1,1,1)*/ data = output_condition ? mem[address] : 'bz;

	initial begin
		$display("=============================================================================================");
		$display("MEMORY INITIALISED with");
		$display("DEPTH = %d, ADDRESS_WIDTH = %d, DATA_WIDTH = %d", DEPTH, ADDR_WIDTH, DATA_WIDTH);
		$display("=============================================================================================");
		$display("");
		$display("");

	end

	always	@(posedge reset) begin
		rdata = mem[address];
	end
	always @(posedge clk) begin
		if(reset) begin
		  if(CS) begin
				case({WE,OE})
					2'b0x : rdata <= mem[address]; //READ
					2'b10 : mem[address] <= data; //WRITE
					2'b11 : $display("%d: ERROR from module memory: OE and WE are 1 at the same time!!", $time);	//INVALID
				endcase
		  end
		end
	end

	task print_mem();
		begin
			for(i = 0; i < DEPTH; i = i+1)
				$display("mem[%d] = %h",i, mem[i]);
		end
	endtask

endmodule
