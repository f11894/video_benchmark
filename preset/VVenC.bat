@echo off
for %%i in ("%~dp0.") do set benchmark_bat="%%~dpivideo_benchmark.bat"
:loop
if "%~1"=="" goto end
for /L %%i in (36,-2,28) do call %benchmark_bat% -codec VVenC -i "%~1" -o "%~n1_VVenC_medium_q%%i.vvc" -cmd "--preset medium -qp %%i" -csvsuf medium_q
shift
goto loop
:end
exit /b
