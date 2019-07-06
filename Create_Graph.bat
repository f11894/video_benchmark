@echo off
rem Drag and drop the benchmark_log folder

cd "%~1"
echo Creating graph
"%~dp0tools\Create_Graph.exe" "%~1"
echo Graph creation finished
pause
