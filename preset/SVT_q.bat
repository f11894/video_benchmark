@echo off
cd "%~dp0"
for %%i in ("..\video_benchmark.bat") do set benchmark_bat="%%~dpnxi"

rem SVTŒn‚Í‚Ü‚¾ˆÀ’è‚µ‚Ä‚¢‚È‚¢
for /L %%i in (50,-2,30) do call %benchmark_bat% "%~1" "%~n1_SVT-VP9_e0_q%%i.mp4" "-enc-mode 0 -q %%i" SVT-VP9 e0
for /L %%i in (50,-2,30) do call %benchmark_bat% "%~1" "%~n1_SVT-AV1_e0_q%%i.mp4" "-enc-mode 0 -q %%i" SVT-AV1 e0
exit /b
