@echo off
for %%i in ("%~dp0.") do set benchmark_bat="%%~dpivideo_benchmark.bat"
:loop
if "%~1"=="" goto end
for /L %%i in (180,-20,100) do call %benchmark_bat% -codec AVM -i "%~1" -o "%~n1_AVM_10bit_c1_1pass_q%%i.ivf" -cmd "--ivf --cpu-used=1 --threads=8 --tile-columns=2 --tile-rows=1 --passes=1 --end-usage=q --qp=%%i --kf-max-dist=250 --lag-in-frames=25 --input-bit-depth=10 --bit-depth=10" -csvsuf 10bit_c1_1pass_q -encode-depth 10

for /L %%i in (32,-2,16) do call %benchmark_bat% -codec VVenC -i "%~1" -o "%~n1_VVenC_10bit_slow_q%%i.mp4" -cmd "--preset slow --WaveFrontSynchro=1 --Tiles=2x1 --threads 12 --InputBitDepth 10 --InternalBitDepth 10 --OutputBitDepth 10 --GOPSize 32 --IntraPeriod 256 --qpa 0 --QP %%i" -csvsuf 10bit_slow_q -encode-depth 10

for /L %%i in (52,-5,17) do call %benchmark_bat% -codec SVT-AV1 -i "%~1" -o "%~n1_SVT-AV1_10bit_p0_1pass_crf%%i.mp4" -cmd "--preset 0 --input-depth 10 --keyint 240 --irefresh-type 2 --crf %%i" -csvsuf 10bit_p0_1pass_crf -encode-depth 10

for /L %%i in (32,-2,18) do call %benchmark_bat% -codec x265 -i "%~1" -o "%~n1_x265_10bit_veryslow_crf%%i.mp4" -cmd "--preset veryslow --crf %%i --input-depth 10 --output-depth 10" -csvsuf 10bit_veryslow_crf -encode-depth 10
shift
goto loop
:end
exit /b
