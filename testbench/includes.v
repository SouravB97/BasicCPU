//timescale
`timescale 1ns/1ps

//defines
//`define BHVR 
`define DATA_WIDTH 8

//includes
`ifdef BHVR

`include "../d_ff_bhvr.v"
`include "../jk_ff_bhvr.v"
`include "../mux_bhvr.v"
`include "../decoder_bhvr.v"
`include "../register_bhvr.v"
`include "../counter_bhvr.v"
`include "../memory_bhvr.v"
`include "../ALU_bhvr.v"

`else //structural

`include "../d_ff.v"
`include "../jk_ff.v"
`include "../mux.v"
`include "../decoder.v"
`include "../register.v"
`include "../counter.v"
`include "../memory_bhvr.v"
`include "../ALU_components.v"
`include "../ALU.v"

`endif



//`include "../clk_divider.v"
