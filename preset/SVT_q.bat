@echo off
for %%i in ("%~dp0.") do set benchmark_bat="%%~dpivideo_benchmark.bat"
:loop
if "%~1"=="" goto end
for /L %%i in (32,-2,18) do call %benchmark_bat% -codec SVT-HEVC -i "%~1" -o "%~n1_SVT-HEVC_encmode1_q%%i.mp4" -cmd "-encMode 1 -profile 1 -q %%i" -csvsuf encmode1_q
for /L %%i in (50,-4,26) do call %benchmark_bat% -codec SVT-VP9 -i "%~1" -o "%~n1_SVT-VP9_encmode1_q%%i.webm" -cmd "-enc-mode 1 -intra-period 63 -q %%i" -csvsuf encmode1_q
for /L %%i in (50,-4,26) do call %benchmark_bat% -codec SVT-AV1 -i "%~1" -o "%~n1_SVT-AV1_encmode2_1pass_q%%i.mp4" -cmd "--preset 2 --keyint 63 --irefresh-type 2 -q %%i" -csvsuf encmode2_1pass_q
rem for /L %%i in (50,-4,26) do call %benchmark_bat% -codec SVT-AV1 -i "%~1" -o "%~n1_SVT-AV1_encmode2_2pass_q%%i.mp4" -cmd "--preset 2 --pass 2 --keyint 63 --irefresh-type 2 -q %%i" -csvsuf encmode2_2pass_q
shift
goto loop
:end
exit /b
