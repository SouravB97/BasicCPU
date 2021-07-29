//timescale
`timescale 1ns/1ps

//`define BHVR
`define DATA_WIDTH 8


`ifdef BHVR
	`include "../d_ff_bhvr.v"
	`include "../jk_ff_bhvr.v"
	`include "../mux_bhvr.v"
	`include "../register_bhvr.v"
	`include "../counter_bhvr.v"

`else //structural
	`include "../d_ff.v"
	`include "../jk_ff.v"
	`include "../mux.v"
	`include "../register.v"
	`include "../counter.v"

`endif
