@echo off
cd "%~dp0"
for %%i in ("..\video_benchmark.bat") do set benchmark_bat="%%~dpnxi"
:loop
if "%~1"=="" goto end
for /L %%i in (160,-20,60) do call %benchmark_bat% "%~1" "%~n1_rav1e_20190713_s2_tunepsnr_1pass_q%%i.mp4" "--quantizer %%i --speed 2 --tune psnr --keyint 250 --threads 8 --tile-cols-log2 2 --tile-rows-log2 2" rav1e 20190713_s2_tunepsnr_1pass_q
for /L %%i in (32,-2,18) do call %benchmark_bat% "%~1" "%~n1_x264_placebo_tunessim_crf%%i.mp4" "--preset placebo --tune ssim --keyint 250 --crf %%i" x264 placebo_tunessim_crf
for /L %%i in (32,-2,18) do call %benchmark_bat% "%~1" "%~n1_x265_placebo_tunessim_crf%%i.mp4" "--preset placebo --tune ssim --keyint 250 --crf %%i" x265 placebo_tunessim_crf
for /L %%i in (55,-5,25) do call %benchmark_bat% "%~1" "%~n1_libvpx_vp9_c0_2pass_q%%i.webm" "--codec=vp9 --frame-parallel=0 --tile-columns=2 --good --cpu-used=0 --tune=psnr --passes=2 --threads=2 --end-usage=q --cq-level=%%i --webm --auto-alt-ref=6 --kf-max-dist=250" libvpx vp9_c0_2pass_q
for /L %%i in (55,-5,25) do call %benchmark_bat% "%~1" "%~n1_libaom_c0_2pass_q%%i.mp4" "--ivf --cpu-used=0 --threads=8 --tile-columns=2 --tile-rows=2 --passes=2 --end-usage=q --cq-level=%%i --kf-max-dist=250" libaom c0_2pass_q
rem 10bit sample
rem for /L %%i in (50,-2,30) do call %benchmark_bat% "%~1" "%~n1_SVT-AV1_10bit_e0_q%%i.mp4" "-enc-mode 0 -q %%i -bit-depth 10" SVT-AV1 10bit_e0 10bit
rem for /L %%i in (32,-2,18) do call %benchmark_bat% "%~1" "%~n1_x264_10bit_placebo_tunessim_crf%%i.mp4" "--preset placebo --tune ssim --crf %%i --input-depth 10 --output-depth 10" x264 10bit_placebo_tunessim_crf 10bit
rem for /L %%i in (32,-2,18) do call %benchmark_bat% "%~1" "%~n1_x265_10bit_placebo_tunessim_crf%%i.mp4" "--preset placebo --tune ssim --crf %%i --input-depth 10 --output-depth 10" x265 10bit_placebo_tunessim_crf 10bit
rem for /L %%i in (55,-5,25) do call %benchmark_bat% "%~1" "%~n1_libaom_10bit_c0_2pass_q%%i.mp4" "--ivf --cpu-used=0 --threads=8 --tile-columns=2 --tile-rows=2 --passes=2 --end-usage=q --cq-level=%%i --kf-max-dist=250 --input-bit-depth=10 --bit-depth=10" libaom 10bit_c0_2pass_q 10bit
shift
goto loop
:end
exit /b
