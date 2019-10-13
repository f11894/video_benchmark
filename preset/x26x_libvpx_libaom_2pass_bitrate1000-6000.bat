@echo off
cd "%~dp0"
for %%i in ("..\video_benchmark.bat") do set benchmark_bat="%%~dpnxi"
:loop
if "%~1"=="" goto end
for /L %%i in (1000,1000,6000) do call %benchmark_bat% -codec rav1e -i "%~1" -o "%~n1_rav1e_20190921_s2_tunepsnr_2pass_%%ikbps.mp4" -cmd "--bitrate %%i --second-pass rav1e_stats.log --speed 2 --tune psnr --keyint 250 --threads 8 --tile-cols 2 --tile-rows 2" -csvsuf 20190921_s2_tunepsnr_2pass_bitrate
for /L %%i in (1000,1000,6000) do call %benchmark_bat% -codec libaom -i "%~1" -o "%~n1_libaom_c0_%%ikbps.mp4" -cmd "--ivf --cpu-used=0 --threads=8 --tile-columns=2 --tile-rows=2 --end-usage=vbr --passes=2 --target-bitrate=%%i --kf-max-dist=250" -csvsuf c0_2pass_bitrate
for /L %%i in (1000,1000,6000) do call %benchmark_bat% -codec x264 -i "%~1" -o "%~n1_x264_placebo_tunessim_%%ikbps.mp4" -cmd "--preset placebo --tune ssim --keyint 250 --bitrate %%i --pass 2" -csvsuf placebo_tunessim_2pass_bitrate
for /L %%i in (1000,1000,6000) do call %benchmark_bat% -codec x265 -i "%~1" -o "%~n1_x265_placebo_tunessim_%%ikbps.mp4" -cmd "--preset placebo --tune ssim --keyint 250 --bitrate %%i --pass 2" -csvsuf placebo_tunessim_2pass_bitrate
for /L %%i in (1000,1000,6000) do call %benchmark_bat% -codec libvpx -i "%~1" -o "%~n1_libvpx_vp9_c0_2pass_crf%%i.webm" -cmd "--codec=vp9 --frame-parallel=0 --tile-columns=2 --good --cpu-used=0 --tune=psnr --passes=2 --threads=2 --end-usage=vbr --target-bitrate=%%i --webm --auto-alt-ref=6 --kf-max-dist=250" -csvsuf vp9_c0_2pass_bitrate

rem 10bit example
rem for /L %%i in (1000,1000,6000) do call %benchmark_bat% -codec x264 -i "%~1" -o "%~n1_x264_10bit_placebo_tunessim_%%ikbps.mp4" -cmd "--preset placebo --tune ssim --bitrate %%i --pass 2 --input-depth 10 --output-depth 10" -csvsuf 10bit_placebo_tunessim_2pass_bitrate -encode-depth 10
rem for /L %%i in (1000,1000,6000) do call %benchmark_bat% -codec x265 -i "%~1" -o "%~n1_x265_10bit_placebo_tunessim_%%ikbps.mp4" -cmd "--preset placebo --tune ssim --bitrate %%i --pass 2 --input-depth 10 --output-depth 10" -csvsuf 10bit_placebo_tunessim_2pass_bitrate -encode-depth 10
shift
goto loop
:end
exit /b
