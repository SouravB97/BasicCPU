# testing
Basic CPU design testing

# How to run:
icarus verilog directly compiles and executes the verilog file passed. 
Since everything is instantiated from TB_TOP, we need to execute that.

cd testbench;
irun cpu_TB.v
gtkwave cpu_TB.vcd

#Load waveform files in signals
