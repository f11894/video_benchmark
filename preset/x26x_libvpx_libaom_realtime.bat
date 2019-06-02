@echo off
cd "%~dp0"
for %%i in ("..\video_benchmark.bat") do set benchmark_bat="%%~dpnxi"
for %%i in (500,750,1000,1500,2000,2500,3000,3500,4000,4500,5000) do call %benchmark_bat% "%~1" "%~n1_libvpx_vp9_c6rt_1pass_%%ikbps.webm" "--codec=vp9 --frame-parallel=1 --row-mt=1 --tile-columns=2 --tile-rows=2 --good --rt --cpu-used=6 --tune=psnr --passes=1 --threads=8 --end-usage=vbr --target-bitrate=%%i --webm --kf-max-dist=60" libvpx vp9_c6rt_1pass_bitrate
for %%i in (500,750,1000,1500,2000,2500,3000,3500,4000,4500,5000) do call %benchmark_bat% "%~1" "%~n1_libaom_c8rt_1pass_%%ikbps.mp4" "--ivf --cpu-used=8 --rt --threads=8 --tile-columns=2 --tile-rows=2 --passes=1 --end-usage=vbr --target-bitrate=%%i --kf-max-dist=60" libaom c8rt_1pass_birate
for %%i in (500,750,1000,1500,2000,2500,3000,3500,4000,4500,5000) do call %benchmark_bat% "%~1" "%~n1_x264_medium_tunessim_%%ikbps.mp4" "--preset medium --tune ssim --keyint 60 --bitrate %%i" x264 medium_tunessim_1pass_bitrate
for %%i in (500,750,1000,1500,2000,2500,3000,3500,4000,4500,5000) do call %benchmark_bat% "%~1" "%~n1_x265_veryfast_tunessim_%%ikbps.mp4" "--preset veryfast --tune ssim --keyint 60 --bitrate %%i" x265 veryfast_tunessim_1pass_bitrate
exit /b
