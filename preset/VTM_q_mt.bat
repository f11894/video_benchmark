@echo off
cd "%~dp0"
for %%i in ("..\video_benchmark.bat") do set benchmark_bat="%%~dpnxi"
for %%i in ("..\ffmediaInfo.bat") do set ffmediaInfo_bat="%%~dpnxi"

for %%i in ("..\tools\xargs.exe") do set xargs="%%~dpnxi"
for %%i in ("..\tools\ffmpeg.exe") do set ffmpeg="%%~dpnxi"
for %%i in ("..\tools\timer64.exe") do set timer64="%%~dpnxi"
for %%i in ("..\tools\vtm\EncoderApp.exe") do set VTM="%%~dpnxi"
for %%i in ("..\tools\vtm\encoder_randomaccess_vtm.cfg") do set "VTM_cfg=%%~dpnxi"

call %ffmediaInfo_bat% "%~1"

set VTM_option="-c %VTM_cfg% --InputBitDepth=8 --OutputBitDepth=8 -q %%i"
set thread=8

if not exist "%~dpn1_temp8bit.yuv" echo 入力に使用する中間ファイルを作成しています&&%ffmpeg% -y -i "%~1" -an -pix_fmt yuv420p -f rawvideo -strict -2 "%~dpn1_temp8bit.yuv"

chcp 65001
set xargs_txt="%TEMP%\xargs_%RANDOM%_%RANDOM%_%RANDOM%.txt"
for /L %%i in (38,-2,22) do (
   echo "%~1" "VTM_q%%i" %VTM_option%>>%xargs_txt%
)
chcp 932
%xargs% -a %xargs_txt% -n 3 -P %thread% "%~dp0VTM_xargs.bat"
for /L %%i in (38,-2,22) do call %benchmark_bat% "%~1" "%~n1_VTM_q%%i.bin" %VTM_option% VTM q
exit /b
