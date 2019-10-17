@echo off
for %%i in ("%~dp0.") do set benchmark_bat="%%~dpivideo_benchmark.bat"
:loop
if "%~1"=="" goto end
for %%a in (ultrafast,superfast,veryfast,faster,fast,medium,slow,slower,veryslow,placebo) do (
   for /L %%i in (32,-2,18) do call %benchmark_bat% -codec x265 -i "%~1" -o "%~n1_x265_%%a_tunessim_crf%%i.mp4" -cmd "--preset %%a --tune ssim --crf %%i" -csvsuf %%a_tunessim_crf
)
shift
goto loop
:end
exit /b
