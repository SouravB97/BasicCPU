ECHO OFF
::no more prints

ECHO My utility for icarus simulator
ECHO Verilog: %1

set v_file=%1
set o_file=%v_file:~0,-2%
set compile_path=C:\Users\soura\Documents\Verilog\compiled

ECHO iverilog -o %compile_path%\%o_file% %v_file%
ECHO vvp %compile_path%\%o_file%
ECHO.
ECHO.
ECHO.

iverilog -o %compile_path%\%o_file% %v_file%
vvp %compile_path%\%o_file%
del %compile_path%\%o_file%

::PAUSE
