
module memory
 #(parameter DEPTH = 256,
 	 parameter DATA_WIDTH = `DATA_WIDTH,
	 parameter ADDR_WIDTH = $clog2(DEPTH))(

	 input [ADDR_WIDTH - 1 :0] address,
	 inout [DATA_WIDTH - 1 :0] data,
	 input CS, RD_WR,
	 input clk
);
	reg [DATA_WIDTH - 1 :0] mem [DEPTH :0] ;
	wire output_condition;
	reg [DATA_WIDTH - 1 :0] rdata;
	integer i;

	assign output_condition = CS & RD_WR;
	assign data = output_condition ? rdata : 'bz;

	initial begin
		$display("=============================================================================================");
		$display("MEMORY INITIALISED with");
		$display("DEPTH = %d, ADDRESS_WIDTH = %d, DATA_WIDTH = %d", DEPTH, ADDR_WIDTH, DATA_WIDTH);
		$display("=============================================================================================");
		$display("");
		$display("");

		//backdoor memory load task here.
		for(i = 0; i < DEPTH; i = i+1)
			mem[i] = ~0;
	end

	always @(posedge clk) begin
		if(CS) begin
			if(RD_WR) begin//READ
				rdata = mem[address];
		  end		
			else begin			//WRITE
				mem[address] = data;
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
