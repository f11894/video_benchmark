@echo off
for %%i in ("%~dp0.") do set benchmark_bat="%%~dpivideo_benchmark.bat"
set num=1
:loop
if "%~1"=="" goto end
for %%a in (ultrafast,superfast,veryfast,faster,fast,medium,slow,slower,veryslow,veryslow) do (
   for /L %%i in (32,-2,18) do call %benchmark_bat% -codec x265 -i "%~1" -o "%~n1_x265_%%num%%_%%a_tunessim_crf%%i.mp4" -cmd "--preset %%a --tune ssim --crf %%i" -csvsuf %%num%%_%%a_tunessim_crf
   set /a num+=1
)
shift
goto loop
:end
exit /b
