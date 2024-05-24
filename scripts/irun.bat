set compile_dir=%USERPROFILE%/Documents/Verilog/compiled
::mv this file to install folder, c:/iverilog/bin
echo off
::no more print
echo My utility to run icarus simulator
echo Verilog file: %1
set v_file=%1
set o_file=%v_file:~0,-2%

if not exist "%compile_dir%" (
    mkdir "%compile_dir%"
    echo %compile_dir% created successfully.
) else (
		echo compile directory: %compile_dir%
)

::make sure to replace the file path with your own
echo iverilog -o %compile_dir%/%o_file% %v_file%
echo vvp %compile_dir%/%o_file%
echo.  

iverilog -o %compile_dir%/%o_file% %v_file%
vvp %compile_dir%/%o_file%

::PAUSE
