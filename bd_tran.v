
/*
	assign t = ctrl ? d : 1'bz;
	assign q = !ctrl ? t : 1'b0;
*/

module bd_tran(
	input d,
	output q,
	inout t,
	input c
);

	tranif1(d,t,c);
	tranif0(t,q,c);

endmodule
