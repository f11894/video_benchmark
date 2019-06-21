@echo off
cd "%~dp0"
for %%i in ("..\video_benchmark.bat") do set benchmark_bat="%%~dpnxi"
:loop
if "%~1"=="" goto end
for /L %%i in (32,-2,18) do call %benchmark_bat% "%~1" "%~n1_SVT-HEVC_encmode0_q%%i.mp4" "-encMode 0 -profile 1 -q %%i" SVT-HEVC encmode0
for /L %%i in (50,-3,26) do call %benchmark_bat% "%~1" "%~n1_SVT-AV1_encmode0_q%%i.mp4" "-enc-mode 0 -intra-period 63 -q %%i" SVT-AV1 encmode0
for /L %%i in (50,-3,26) do call %benchmark_bat% "%~1" "%~n1_SVT-VP9_encmode0_q%%i.webm" "-enc-mode 0 -intra-period 63 -q %%i" SVT-VP9 encmode0
shift
goto loop
:end
exit /b
