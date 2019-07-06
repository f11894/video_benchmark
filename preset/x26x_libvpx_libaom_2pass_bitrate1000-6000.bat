@echo off
cd "%~dp0"
for %%i in ("..\video_benchmark.bat") do set benchmark_bat="%%~dpnxi"
:loop
if "%~1"=="" goto end
for /L %%i in (1000,1000,6000) do call %benchmark_bat% "%~1" "%~n1_libaom_c0_%%ikbps.mp4" "--ivf --cpu-used=0 --threads=8 --tile-columns=2 --tile-rows=2 --end-usage=vbr --passes=2 --target-bitrate=%%i --kf-max-dist=250" libaom c0_2pass_bitrate
for /L %%i in (1000,1000,6000) do call %benchmark_bat% "%~1" "%~n1_x264_placebo_tunessim_%%ikbps.mp4" "--preset placebo --tune ssim --keyint 250 --bitrate %%i --pass 2" x264 placebo_tunessim_2pass_bitrate
for /L %%i in (1000,1000,6000) do call %benchmark_bat% "%~1" "%~n1_x265_placebo_tunessim_%%ikbps.mp4" "--preset placebo --tune ssim --keyint 250 --bitrate %%i --pass 2" x265 placebo_tunessim_2pass_bitrate
for /L %%i in (1000,1000,6000) do call %benchmark_bat% "%~1" "%~n1_libvpx_vp9_c0_2pass_crf%%i.webm" "--codec=vp9 --frame-parallel=0 --tile-columns=2 --good --cpu-used=0 --tune=psnr --passes=2 --threads=2 --end-usage=vbr --target-bitrate=%%i --webm --auto-alt-ref=6 --kf-max-dist=250" libvpx vp9_c0_2pass_bitrate

rem 10bit sample
rem for /L %%i in (1000,1000,6000) do call %benchmark_bat% "%~1" "%~n1_x264_10bit_placebo_tunessim_%%ikbps.mp4" "--preset placebo --tune ssim --bitrate %%i --pass 2 --input-depth 10 --output-depth 10" x264 10bit_placebo_tunessim_2pass_bitrate 10bit
rem for /L %%i in (1000,1000,6000) do call %benchmark_bat% "%~1" "%~n1_x265_10bit_placebo_tunessim_%%ikbps.mp4" "--preset placebo --tune ssim --bitrate %%i --pass 2 --input-depth 10 --output-depth 10" x265 10bit_placebo_tunessim_2pass_bitrate 10bit
shift
goto loop
:end
exit /b
