@echo off
for %%i in ("%~dp0.") do set benchmark_bat="%%~dpivideo_benchmark.bat"
:loop
if "%~1"=="" goto end
for /L %%i in (180,-20,100) do call %benchmark_bat% -codec AVM -i "%~1" -o "%~n1_AVM_10bit_c1_1pass_q%%i.ivf" -cmd "--ivf --cpu-used=1 --threads=8 --tile-columns=2 --tile-rows=1 --passes=1 --end-usage=q --qp=%%i --kf-max-dist=250 --lag-in-frames=25 --input-bit-depth=10 --bit-depth=10" -csvsuf 10bit_c1_1pass_q -encode-depth 10

for /L %%i in (52,-5,17) do call %benchmark_bat% -codec SVT-AV1 -i "%~1" -o "%~n1_SVT-AV1_10bit_p0_1pass_crf%%i.mp4" -cmd "--preset 0 --input-depth 10 --keyint 240 --irefresh-type 2 --crf %%i" -csvsuf 10bit_p0_1pass_crf -encode-depth 10

for /L %%i in (55,-5,25) do call %benchmark_bat% -codec libaom -i "%~1" -o "%~n1_libaom_10bit_c0_2pass_q%%i.mp4" -cmd "--ivf --cpu-used=0 --threads=8 --tile-columns=2 --tile-rows=1 --pass=2 --passes=2 --end-usage=q --cq-level=%%i --kf-max-dist=250 --lag-in-frames=25 --input-bit-depth=10 --bit-depth=10" -csvsuf 10bit_c0_2pass_q -encode-depth 10


shift
goto loop
:end
exit /b
