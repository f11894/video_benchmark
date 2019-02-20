@echo off
cd "%~dp0"
for %%i in ("..\video_benchmark.bat") do set benchmark_bat="%%~dpnxi"

for %%a in (ultrafast,superfast,veryfast,faster,fast,medium,slow,slower,veryslow,placebo) do (
   for /L %%i in (32,-2,18) do call %benchmark_bat% "%~1" "%~n1_x265_%%a_tunessim_crf%%i.mp4" "--preset %%a --tune ssim --crf %%i" x265 %%a_tunessim_crf
)
exit /b
