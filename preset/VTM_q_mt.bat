@echo off
cd "%~dp0"
for %%i in ("..\video_benchmark.bat") do set benchmark_bat="%%~dpnxi"
for %%i in ("..\ffmediaInfo.bat") do set ffmediaInfo_bat="%%~dpnxi"

for %%i in ("..\tools\busybox64.exe") do set busybox64="%%~dpnxi"
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
for /L %%i in (36,-2,22) do (
   echo "%~1" "VTM_q%%i" %VTM_option%>>%xargs_txt%
)
chcp 932
%busybox64% xargs -a %xargs_txt%  -n 3 -P %thread% "%~dp0VTM_xargs.bat"
for /L %%i in (36,-2,22) do call %benchmark_bat% "%~1" "%~n1_VTM_q%%i.bin" %VTM_option% VTM q

rem 比較用
for /L %%i in (32,-2,18) do call %benchmark_bat% "%~1" "%~n1_x264_placebo_tunessim_kf32_crf%%i.mp4" "--preset placebo --tune ssim --keyint 32 --crf %%i" x264 placebo_tunessim_kf32_crf
for /L %%i in (32,-2,18) do call %benchmark_bat% "%~1" "%~n1_x265_placebo_tunessim_kf32_crf%%i.mp4" "--preset placebo --tune ssim --keyint 32 --crf %%i" x265 placebo_tunessim_kf32_crf

for /L %%i in (55,-5,25) do call %benchmark_bat% "%~1" "%~n1_libvpx_vp9_c0_kf32_2pass_q%%i.webm" "--codec=vp9 --frame-parallel=0 --tile-columns=2 --good --cpu-used=0 --tune=psnr --passes=2 --threads=2 --end-usage=q --cq-level=%%i --webm --auto-alt-ref=6 --kf-max-dist=32" libvpx vp9_c0_kf32_2pass_q

for /L %%i in (55,-5,25) do call %benchmark_bat% "%~1" "%~n1_libaom_c0_kf32_2pass_q%%i.mp4" "--ivf --cpu-used=0 --threads=8 --tile-columns=2 --tile-rows=2 --passes=2 --end-usage=q --cq-level=%%i --kf-max-dist=32" libaom c0_kf32_2pass_q

exit /b
