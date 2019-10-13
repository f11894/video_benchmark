@echo off
cd "%~dp0"
for %%i in ("..\video_benchmark.bat") do set benchmark_bat="%%~dpnxi"
:loop
if "%~1"=="" goto end
for %%i in (500,750,1000,1500,2000,2500,3000,3500,4000,4500,5000) do call %benchmark_bat% -codec libvpx -i "%~1" -o "%~n1_libvpx_vp9_c6rt_1pass_%%ikbps.webm" -cmd "--codec=vp9 --frame-parallel=1 --row-mt=1 --tile-columns=2 --tile-rows=2 --good --rt --cpu-used=6 --tune=psnr --passes=1 --threads=8 --end-usage=vbr --target-bitrate=%%i --webm --kf-max-dist=60" -csvsuf vp9_c6rt_1pass_bitrate
for %%i in (500,750,1000,1500,2000,2500,3000,3500,4000,4500,5000) do call %benchmark_bat% -codec libaom -i "%~1" -o "%~n1_libaom_c8rt_1pass_%%ikbps.mp4" -cmd "--ivf --cpu-used=8 --rt --threads=8 --tile-columns=2 --tile-rows=2 --passes=1 --end-usage=vbr --target-bitrate=%%i --kf-max-dist=60" -csvsuf c8rt_1pass_birate
for %%i in (500,750,1000,1500,2000,2500,3000,3500,4000,4500,5000) do call %benchmark_bat% -codec x264 -i "%~1" -o "%~n1_x264_medium_tunessim_%%ikbps.mp4" -cmd "--preset medium --tune ssim --keyint 60 --bitrate %%i" -csvsuf medium_tunessim_1pass_bitrate
for %%i in (500,750,1000,1500,2000,2500,3000,3500,4000,4500,5000) do call %benchmark_bat% -codec x265 -i "%~1" -o "%~n1_x265_veryfast_tunessim_%%ikbps.mp4" -cmd "--preset veryfast --tune ssim --keyint 60 --bitrate %%i" -csvsuf veryfast_tunessim_1pass_bitrate
shift
goto loop
:end
exit /b
