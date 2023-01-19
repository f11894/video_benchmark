@echo off
set plot="%~dp0tools\plot.exe"
rem Drag and drop the benchmark_log folder
echo Make plot
:start
if "%~1"=="" goto end
cd /d "%~1"
%plot% "%~1"
shift
goto start
:end
echo Plot making finished
pause
exit /b
