@echo off
for %%i in ("%~dp0.") do set benchmark_bat="%%~dpivideo_benchmark.bat"
:loop
if "%~1"=="" goto end
for /L %%i in (32,-2,18) do call %benchmark_bat% -codec SVT-HEVC -i "%~1" -o "%~n1_SVT-HEVC_encmode1_q%%i.mp4" -cmd "-encMode 1 -profile 1 -q %%i" -csvsuf encmode1_q
for /L %%i in (50,-4,26) do call %benchmark_bat% -codec SVT-VP9 -i "%~1" -o "%~n1_SVT-VP9_encmode1_q%%i.webm" -cmd "-enc-mode 1 -intra-period 63 -q %%i" -csvsuf encmode1_q

for /L %%i in (50,-4,26) do (
    call %benchmark_bat% -codec SVT-AV1 -i "%~1" -o "%~n1_SVT-AV1_encmode5_1pass_q%%i.mp4" -cmd "-enc-mode 5 -output-stat-file svtav1_q%%i.stat -enc-mode-2p 1 -intra-period 63 -q %%i" -csvsuf encmode5_1pass_q
    call %benchmark_bat% -codec SVT-AV1 -i "%~1" -o "%~n1_SVT-AV1_encmode1_2pass_q%%i.mp4" -cmd "-enc-mode 1 -input-stat-file svtav1_q%%i.stat -intra-period 63 -q %%i" -csvsuf encmode1_2pass_q
    del "%~dp1svtav1_q%%i.stat"
)
shift
goto loop
:end
exit /b
