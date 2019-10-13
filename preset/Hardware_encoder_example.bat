@echo off
cd "%~dp0"
for %%i in ("..\video_benchmark.bat") do set benchmark_bat="%%~dpnxi"
:loop
if "%~1"=="" goto end
rem VCEEncC
rem for /L %%i in (36,-2,18) do call %benchmark_bat% -codec VCEEncC -i "%~1" -o "%~n1_VCEEncC_slow_h265_cqp%%i.mp4" -cmd "--codec hevc --quality slow --cqp %%i" -csvsuf slow_h265_cqp
rem for /L %%i in (36,-2,18) do call %benchmark_bat% -codec VCEEncC -i "%~1" -o "%~n1_VCEEncC_slow_h264_cqp%%i.mp4" -cmd "--codec h264 --quality slow --cqp %%i" -csvsuf slow_h264_cqp

rem QSVEncC
rem for /L %%H in (44,-4,20) do call %benchmark_bat% -codec QSVEncC -i "%~1" -o "%~n1_QSVEncC_best_h264_laicq%%H.mp4" -cmd "--codec h264 --quality best --la-icq %%H" -csvsuf best_h264_laicq

rem For comparison
for /L %%i in (32,-2,18) do call %benchmark_bat% -codec x264 -i "%~1" -o "%~n1_x264_medium_tunessim_crf%%i.mp4" -cmd "--preset medium --tune ssim --keyint 250 --crf %%i" -csvsuf medium_tunessim_crf
for /L %%i in (32,-2,18) do call %benchmark_bat% -codec x265 -i "%~1" -o "%~n1_x265_medium_tunessim_crf%%i.mp4" -cmd "--preset medium --tune ssim --keyint 250 --crf %%i" -csvsuf medium_tunessim_crf
shift
goto loop
:end
exit /b
