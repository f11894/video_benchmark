@echo off
for %%i in ("%~dp0.") do set benchmark_bat="%%~dpivideo_benchmark.bat"
:loop
if "%~1"=="" goto end
rem for /L %%i in (32,-2,18) do call %benchmark_bat% -codec SVT-HEVC -i "%~1" -o "%~n1_SVT-HEVC_encmode1_q%%i.mp4" -cmd "-encMode 1 -profile 1 -q %%i" -csvsuf encmode1_q
rem for /L %%i in (50,-4,22) do call %benchmark_bat% -codec SVT-VP9 -i "%~1" -o "%~n1_SVT-VP9_encmode1_q%%i.webm" -cmd "-enc-mode 1 -intra-period 255 -q %%i" -csvsuf encmode1_q
for %%a in (8,7) do (
    for /L %%i in (52,-5,17) do call %benchmark_bat% -codec SVT-AV1 -i "%~1" -o "%~n1_SVT-AV1_p%%a_1pass_crf%%i.mp4" -cmd "--preset %%a --keyint 240 --irefresh-type 2 --crf %%i" -csvsuf p%%a_1pass_crf
)
set num=1
for %%a in (medium,slow) do (
   for /L %%i in (32,-2,18) do call %benchmark_bat% -codec x265 -i "%~1" -o "%~n1_x265_%%num%%_%%a_crf%%i.mp4" -cmd "--preset %%a --keyint 240 --crf %%i" -csvsuf %%num%%_%%a_crf
   set /a num+=1
)
rem for /L %%i in (52,-5,17) do call %benchmark_bat% -codec SVT-AV1 -i "%~1" -o "%~n1_SVT-AV1_p8_2pass_crf%%i.mp4" -cmd "--preset 8 --pass 2 --keyint 240 --irefresh-type 2 --crf %%i" -csvsuf p8_2pass_crf
shift
goto loop
:end
exit /b
