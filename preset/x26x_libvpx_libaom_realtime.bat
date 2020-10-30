@echo off
for %%i in ("%~dp0.") do set benchmark_bat="%%~dpivideo_benchmark.bat"
:loop
if "%~1"=="" goto end
for %%i in (500,750,1000,1500,2000,2500,3000,3500,4000,4500,5000) do call %benchmark_bat% -codec libvpx -i "%~1" -o "%~n1_libvpx_vp9_c6rt_1pass_%%ikbps.webm" -cmd "--codec=vp9 --webm --good --rt --cpu-used=6 --tune=psnr --threads=8 --tile-columns=2 --tile-rows=1 --passes=1 --auto-alt-ref=6 --kf-max-dist=60 --lag-in-frames=0 --end-usage=vbr --target-bitrate=%%i" -csvsuf vp9_c6rt_1pass_bitrate
for %%i in (500,750,1000,1500,2000,2500,3000,3500,4000,4500,5000) do call %benchmark_bat% -codec libaom -i "%~1" -o "%~n1_libaom_c8rt_1pass_%%ikbps.mp4" -cmd "--ivf --cpu-used=8 --rt --threads=8 --tile-columns=2 --tile-rows=1 --passes=1 --kf-max-dist=60 --lag-in-frames=0 --end-usage=vbr --target-bitrate=%%i" -csvsuf c8rt_1pass_birate
for %%i in (500,750,1000,1500,2000,2500,3000,3500,4000,4500,5000) do call %benchmark_bat% -codec x264 -i "%~1" -o "%~n1_x264_medium_tunessim_%%ikbps.mp4" -cmd "--preset medium --tune ssim --keyint 60 --rc-lookahead 0 --sync-lookahead 0 --bframes 0 --bitrate %%i" -csvsuf medium_tunessim_1pass_bitrate
for %%i in (500,750,1000,1500,2000,2500,3000,3500,4000,4500,5000) do call %benchmark_bat% -codec x265 -i "%~1" -o "%~n1_x265_veryfast_tunessim_%%ikbps.mp4" -cmd "--preset veryfast --tune ssim --keyint 60 --lookahead 0 --bframes 0 --bitrate %%i" -csvsuf veryfast_tunessim_1pass_bitrate
shift
goto loop
:end
exit /b
