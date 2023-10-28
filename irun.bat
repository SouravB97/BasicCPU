::mv this file to install folder, c:/iverilog/bin
ECHO OFF
::no more print
ECHO My utility to run icarus simulator
ECHO Verilog file: %1
set v_file=%1
set o_file=%v_file:~0,-2%

::make sure to replace the file path with your own
ECHO iverilog -o C:\Users\soura\Documents\Verilog\compiled\%o_file% %v_file%
ECHO vvp C:\Users\soura\Documents\Verilog\compiled\%o_file%
ECHO.  

iverilog -o C:\Users\soura\Documents\Verilog\compiled\%o_file% %v_file%
vvp C:\Users\soura\Documents\Verilog\compiled\%o_file%

::PAUSE
