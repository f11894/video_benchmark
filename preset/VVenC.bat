@echo off
for %%i in ("%~dp0.") do set benchmark_bat="%%~dpivideo_benchmark.bat"
set ComparePixelFormat=-pix_fmt yuv420p10le
:loop
if "%~1"=="" goto end
for %%a in (5,3,1) do (
    for /L %%i in (52,-5,17) do call %benchmark_bat% -codec SVT-AV1 -i "%~1" -o "%~n1_SVT-AV1_10bit_p%%a_1pass_crf%%i.mp4" -cmd "--preset %%a --input-depth 10 --keyint 240 --irefresh-type 2 --crf %%i" -csvsuf 10bit_p%%a_1pass_crf -encode-depth 10
)
set num=4
for %%a in (slow, medium, fast, faster) do (
   for /L %%i in (32,-2,16) do call %benchmark_bat% -codec VVenC -i "%~1" -o "%~n1_VVenC_10bit_%%num%%_%%a_q%%i.vvc" -cmd "--preset %%a --WaveFrontSynchro=1 --Tiles=2x1 --threads 12 --InputBitDepth 10 --InternalBitDepth 10 --OutputBitDepth 10 --GOPSize 32 --qpa 0 --QP %%i" -csvsuf 10bit_%%num%%_%%a_q -encode-depth 10
   set /a num=num-1
)
shift
goto loop
:end
exit /b
