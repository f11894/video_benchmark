@echo off
for %%i in ("%~dp0.") do set benchmark_bat="%%~dpivideo_benchmark.bat"
set ComparePixelFormat=-pix_fmt yuv420p10le

:loop
if "%~1"=="" goto end
rem VCEEncC
rem for /L %%i in (36,-3,18) do call %benchmark_bat% -codec VCEEncC -i "%~1" -o "%~n1_VCEEncC_slow_h265_cqp%%i.mp4" -cmd "--codec hevc --quality slow --cqp %%i" -csvsuf slow_h265_cqp
rem for /L %%i in (36,-3,18) do call %benchmark_bat% -codec VCEEncC -i "%~1" -o "%~n1_VCEEncC_slow_h264_cqp%%i.mp4" -cmd "--codec h264 --quality slow --cqp %%i" -csvsuf slow_h264_cqp

rem QSVEncC
rem for /L %%i in (44,-4,20) do call %benchmark_bat% -codec QSVEncC -i "%~1" -o "%~n1_QSVEncC_best_h264_laicq%%i.mp4" -cmd "--la-icq %%i --la-depth 60 -u 1" -csvsuf best_h264_laicq
rem for /L %%i in (44,-4,20) do call %benchmark_bat% -codec QSVEncC -i "%~1" -o "%~n1_QSVEncC_best_hevc_laicq%%i.mp4" -cmd "--icq %%i -u 1 -c hevc" -csvsuf best_hevc_laicq
rem for /L %%i in (44,-4,20) do call %benchmark_bat% -codec QSVEncC -i "%~1" -o "%~n1_QSVEncC_10bit_best_hevc_laicq%%i.mp4" -cmd "--icq %%i -u 1 -c hevc --profile main10 --output-depth 10" -csvsuf 10bit_best_hevc_laicq -encode-depth 10

rem NVEncC
rem for /L %%i in (40,-2,24) do call %benchmark_bat% -codec NVEncC -i "%~1" -o "%~n1_NVEncC_h264_q%%i.mp4" -cmd "--vbrhq 0 --vbr-quality %%i --preset quality --weightp --bref-mode each --lookahead 32 --level 5.2" -csvsuf h264_q
rem for /L %%i in (40,-2,24) do call %benchmark_bat% -codec NVEncC -i "%~1" -o "%~n1_NVEncC_hevc_q%%i.mp4" -cmd "--vbrhq 0 --vbr-quality %%i --preset quality --weightp --bref-mode each --lookahead 32 -c hevc --level 6" -csvsuf hevc_q
rem for /L %%i in (40,-2,24) do call %benchmark_bat% -codec NVEncC -i "%~1" -o "%~n1_NVEncC_10bit_hevc_q%%i.mp4" -cmd "--vbrhq 0 --vbr-quality %%i --preset quality --weightp --bref-mode each --lookahead 32 -c hevc --level 6 --output-depth 10" -csvsuf 10bit_hevc_q -encode-depth 10
rem for /L %%i in (40,-2,24) do call %benchmark_bat% -codec NVEncC -i "%~1" -o "%~n1_NVEncC_hevc_Bframes_q%%i.mp4" -cmd "--vbrhq 0 --vbr-quality %%i --preset quality --weightp --bref-mode each --lookahead 32 -c hevc --level 6 -b 3" -csvsuf hevc_Bframes_q
rem for /L %%i in (40,-2,24) do call %benchmark_bat% -codec NVEncC -i "%~1" -o "%~n1_NVEncC_10bit_hevc_Bframes_q%%i.mp4" -cmd "--vbrhq 0 --vbr-quality %%i --preset quality --weightp --bref-mode each --lookahead 32 -c hevc --level 6 --output-depth 10 -b 3" -csvsuf 10bit_hevc_Bframes_q -encode-depth 10

rem For comparison
for /L %%i in (32,-2,18) do call %benchmark_bat% -codec x264 -i "%~1" -o "%~n1_x264_medium_tunessim_crf%%i.mp4" -cmd "--preset medium --tune ssim --keyint 250 --crf %%i" -csvsuf medium_tunessim_crf
for /L %%i in (32,-2,18) do call %benchmark_bat% -codec x265 -i "%~1" -o "%~n1_x265_medium_tunessim_crf%%i.mp4" -cmd "--preset medium --tune ssim --keyint 250 --crf %%i" -csvsuf medium_tunessim_crf
shift
goto loop
:end
exit /b
