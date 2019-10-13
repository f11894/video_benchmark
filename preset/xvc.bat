@echo off
cd "%~dp0"
for %%i in ("..\video_benchmark.bat") do set benchmark_bat="%%~dpnxi"
:loop
if "%~1"=="" goto end
for /L %%i in (36,-2,28) do call %benchmark_bat% -codec xvc -i "%~1" -o "%~n1_xvc_s1_q%%i.xvc" -cmd "-internal-bitdepth 8 -max-keypic-distance 32 -tune 1 -qp %%i" -csv s1_q
shift
goto loop
:end
exit /b
