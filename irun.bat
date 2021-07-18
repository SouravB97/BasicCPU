ECHO OFF
::no more prints

ECHO My utility for icarus simulator
ECHO Verilog: %1

set v_file=%1
set o_file=%v_file:~0,-2%

ECHO iverilog -o C:\Users\soura\Documents\Verilog\compiled\%o_file% %v_file%
ECHO vvp C:\Users\soura\Documents\Verilog\compiled\%o_file%
ECHO.
ECHO.
ECHO.

iverilog -o C:\Users\soura\Documents\Verilog\compiled\%o_file% %v_file%
vvp C:\Users\soura\Documents\Verilog\compiled\%o_file%
del C:\Users\soura\Documents\Verilog\compiled\%o_file%

::PAUSE
