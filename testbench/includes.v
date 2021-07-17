//`define BHVR

`ifdef BHVR
	`include "../d_ff_bhvr.v"
	`include "../jk_ff_bhvr.v"

`else //structural
	`include "../d_ff.v"
	`include "../jk_ff.v"

`endif
