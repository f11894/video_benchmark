@echo off
for %%i in ("%~dp0.") do set benchmark_bat="%%~dpivideo_benchmark.bat"
:loop
if "%~1"=="" goto end
for %%a in (5, 4, 3, 2, 1) do (
   for /L %%i in (60,-5,30) do call %benchmark_bat% -codec libaom -i "%~1" -o "%~n1_libaom_10bit_c%%a_2pass_q%%i.mp4" -cmd "--ivf --cpu-used=%%a --threads=8 --tile-columns=2 --tile-rows=1 --pass=2 --passes=2 --end-usage=q --cq-level=%%i --kf-max-dist=32 --input-bit-depth=10 --bit-depth=10" -csvsuf 10bit_c%%a_2pass_q -encode-depth 10
)
set num=1
for %%a in (faster, fast, medium, slow) do (
   for /L %%i in (34,-2,22) do call %benchmark_bat% -codec VVenC -i "%~1" -o "%~n1_VVenC_10bit_%%num%%_%%a_q%%i.vvc" -cmd "--preset %%a --threads 8 --format yuv420_10 --qpa 0 --qp %%i" -csvsuf 10bit_%%num%%_%%a_q -encode-depth 10
   set /a num+=1
)
shift
goto loop
:end
exit /b
