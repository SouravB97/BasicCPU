
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
	assign data = output_condition ? rdata : 'bz;

	initial begin
		$display("=============================================================================================");
		$display("MEMORY INITIALISED with");
		$display("DEPTH = %d, ADDRESS_WIDTH = %d, DATA_WIDTH = %d", DEPTH, ADDR_WIDTH, DATA_WIDTH);
		$display("=============================================================================================");
		$display("");
		$display("");

		//clear memory
		for(i = 0; i < DEPTH; i = i+1)
			if(ID == 1) mem[i] = 0;
			else mem[i] = ~0;

		//backdoor memory load task here.
		if(ID == 0)
			$readmemh("bootcode.hex", mem); //must be same folder as tb top, where irun is run
		else if(ID == 1)
			$readmemh("micro_code.hex", mem);

		//print_mem();
	end

	always @(posedge clk) begin
		if(reset) begin
		  if(CS) begin
				case({WE,OE})
					2'b00 : ; //DO NOTHING
					2'b01 : rdata = mem[address]; //READ
					2'b10 : mem[address] = data; //WRITE
					2'b11 : $display("ERROR from module memory: OE and WE are 1 at the same time!!");	//INVALID
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
