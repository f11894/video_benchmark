@echo off
cd "%~dp0"
for %%i in ("..\video_benchmark.bat") do set benchmark_bat="%%~dpnxi"

for %%i in ("..\tools\xargs.exe") do set xargs="%%~dpnxi"
for %%i in ("..\tools\ffmpeg.exe") do set ffmpeg="%%~dpnxi"
for %%i in ("..\tools\timer64.exe") do set timer64="%%~dpnxi"
for %%i in ("..\tools\rav1e-20190205-v0.1.0-2cec0f9.exe") do set rav1e="%%~dpnxi"
for %%i in ("..\tools\mp4box.exe") do set mp4box="%%~dpnxi"

set rav1e_option="--quantizer %%i --speed 2 --tune psnr --keyint 250 --low_latency false"
set thread=8

chcp 65001
set xargs_txt="%TEMP%\xargs_%RANDOM%_%RANDOM%_%RANDOM%.txt"
for /L %%i in (160,-20,60) do (
   echo "%~1" "rav1e_20190205_s2_tunepsnr_low_latency_false_q%%i" %rav1e_option%>>%xargs_txt%
)
chcp 932
%xargs% -a %xargs_txt% -n 3 -P %thread% "%~dp0rav1e_xargs.bat"
for /L %%i in (160,-20,60) do call %benchmark_bat% "%~1" "%~n1_rav1e_20190205_s2_tunepsnr_low_latency_false_q%%i.mp4" %rav1e_option% rav1e 20190205_s2_tunepsnr_low_latency_false
exit /b
