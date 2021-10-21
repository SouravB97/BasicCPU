//timescale
`timescale 1ns/1ps

//defines
//`define BHVR 
`define DATA_WIDTH 8

//includes
`ifdef BHVR

`include "../design/BHVR/d_ff_bhvr.v"
`include "../design/BHVR/jk_ff_bhvr.v"
`include "../design/BHVR/mux_bhvr.v"
`include "../design/BHVR/decoder_bhvr.v"
`include "../design/BHVR/register_bhvr.v"
`include "../design/BHVR/counter_bhvr.v"
`include "../design/BHVR/memory_bhvr2.v"
`include "../design/BHVR/ALU_bhvr.v"

`else //structural

`include "../design/d_ff.v"
`include "../design/jk_ff.v"
`include "../design/tri_state_buffer.v"
`include "../design/mux.v"
`include "../design/decoder.v"
`include "../design/register.v"
`include "../design/counter.v"
`include "../design/BHVR/memory_bhvr2.v"
`include "../design/ALU_components.v"
`include "../design/ALU.v"
`include "../design/CPU.v"

`endif



//`include "../design/clk_divider.v"
