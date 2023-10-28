`include "includes.vh"

module ALU_tb();
	reg [`DATA_WIDTH -1:0] A,B;
	reg [4:0] opcode;

	reg [`DATA_WIDTH-1:0] refC;
	reg [3:0] refStatus;

	integer i,j;
	integer opcode_arr[14:0];

	initial begin
		opcode_arr[0]  = `LD ;
		opcode_arr[1]  = `INC;
		opcode_arr[2]  = `ADD;
		opcode_arr[3]  = `ADC;
		opcode_arr[4]  = `SBB;
		opcode_arr[5]  = `SUB;
		opcode_arr[6]  = `DEC;
		opcode_arr[7]  = `LD1;
		opcode_arr[8]  = `AND;
		opcode_arr[9]  = `OR ;
		opcode_arr[10] = `XOR;
		opcode_arr[11] = `CMP;
		opcode_arr[12] = `LSH;
		opcode_arr[13] = `RSH;
	end

	//instantiate DUT
	ALU alu(.A(A),.B(B),.opcode(opcode));

	initial begin
		$dumpfile("ALU_tb.vcd");
		$dumpvars(0,ALU_tb);
		$timeformat(-9, 2, " ns", 20);

		$printtimescale;
	end


	initial begin

		for(i = 12; i < 14; i=i+1) begin //run entire test i times
			for(j = 0; j < 1000; j = j+1) begin //test each opcode j times
				//stimulus generation
				A = $urandom;
				B = $urandom;
				opcode = opcode_arr[i];//$urandom_range(0,opcode_arr[i]);
				#1;
				{refStatus,refC} = ref_model(A,B,opcode);

				//scoreboard
				if(alu.C == refC && alu.status == refStatus)
					$display("%d,%d, PASS: C = %d, refC = %d, status = %b, refStatus = %b",i,j,alu.C,refC,alu.status,refStatus);
				else
					$display("%d,%d, FAIL: C = %d, refC = %d, status = %b, refStatus = %b",i,j,alu.C,refC,alu.status,refStatus);
			end
		end

		$finish();
	end

	//monitor
	initial begin
		$monitor(  "A: %0d\t\t|%b"  , A,A,
             "\nB: %0d\t\t|%b" , B,B,
             "\nC: %0d\t\t|%b" , alu.C,alu.C,
             "\nOpcode: %0x " , opcode,
             "\nStatus{sign, zero, parity, carry}: %0b "      , alu.status);
	end

	//reference model
	function [`DATA_WIDTH + 3 :0] ref_model;
		input [`DATA_WIDTH-1:0] A;
		input [`DATA_WIDTH-1:0] B;
		input[4:0] opcode;

		reg [`DATA_WIDTH:0] C;
		reg [3:0] status;

		begin
			case(opcode)
			'h00: C = A;
			'h01:	C = A+1;
			'h02: C = A+B;
			'h03:	C = A + B + 1; 
			'h04:	C = A - B -1;		 
			'h05:	C = A - B;
			'h06:	C = A - 1;		 
			'h07:	C = A;				 
			'h08,'h09: C = A & B;		 
			'h0A,'h0B: C = A | B;		 
			'h0C,'h0D: C = A ^ B;		 
			'h0E,'h0F: C = ~B;				 
			default: begin
				if(opcode[4:3] == 'b10) C = A >> 1;
				if(opcode[4:3] == 'b11) C = A << 1;
			end
			endcase	

			status[3] = C[`DATA_WIDTH-1];
			status[2] = (C[`DATA_WIDTH-1 :0] == 0);
			status[1] = ^C[`DATA_WIDTH-1 :0]; //EVEN parity
			status[0] = C[`DATA_WIDTH];

			ref_model = {status,C[`DATA_WIDTH-1 :0]};
		end
	endfunction

endmodule
