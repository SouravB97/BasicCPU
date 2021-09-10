#!/bin/bash
echo My utility for icarus simulator
v_file="$1"
echo Verilog: ${v_file}

o_file=$(echo ${v_file} | sed 's/\..*//')
compile_path="${HOME}/Documents/Verilog/compiled/"

echo iverilog -o ${compile_path}${o_file} ${v_file}
echo vvp ${compile_path}${o_file}
echo
echo
echo


iverilog -o "${compile_path}${o_file}" ${v_file}
vvp ${compile_path}${o_file}
rm -rf ${compile_path}${o_file}

