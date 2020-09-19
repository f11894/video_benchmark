@echo off
rem Drag and drop the benchmark_log folder

cd "%~1"
echo Make plot
"%~dp0tools\plot.exe" "%~1"
echo Plot making finished
pause
