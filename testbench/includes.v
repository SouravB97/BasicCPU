//timescale
`timescale 1ns/1ps

//defines
//`define BHVR 
`define DATA_WIDTH 8

//includes
`ifdef BHVR

`include "../design/d_ff_bhvr.v"
`include "../design/jk_ff_bhvr.v"
`include "../design/mux_bhvr.v"
`include "../design/decoder_bhvr.v"
`include "../design/register_bhvr.v"
`include "../design/counter_bhvr.v"
`include "../design/memory_bhvr.v"
`include "../design/ALU_bhvr.v"

`else //structural

`include "../design/d_ff.v"
`include "../design/jk_ff.v"
`include "../design/mux.v"
`include "../design/decoder.v"
`include "../design/register.v"
`include "../design/counter.v"
`include "../design/memory_bhvr.v"
`include "../design/ALU_components.v"
`include "../design/ALU.v"

`endif



//`include "../design/clk_divider.v"
