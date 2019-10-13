@echo off
cd "%~dp0"
for %%i in ("..\video_benchmark.bat") do set benchmark_bat="%%~dpnxi"
:loop
if "%~1"=="" goto end
for /L %%i in (160,-20,60) do call %benchmark_bat% -codec rav1e -i "%~1" -o "%~n1_rav1e_20190921_s2_tunepsnr_1pass_q%%i.mp4" -cmd "--quantizer %%i --speed 2 --tune psnr --keyint 250 --threads 8 --tile-cols 2 --tile-rows 2" -csv 20190921_s2_tunepsnr_1pass_q
for /L %%i in (32,-2,18) do call %benchmark_bat% -codec x264 -i "%~1" -o "%~n1_x264_placebo_tunessim_crf%%i.mp4" -cmd "--preset placebo --tune ssim --keyint 250 --crf %%i" -csv placebo_tunessim_crf
for /L %%i in (32,-2,18) do call %benchmark_bat% -codec x265 -i "%~1" -o "%~n1_x265_placebo_tunessim_crf%%i.mp4" -cmd "--preset placebo --tune ssim --keyint 250 --crf %%i" -csv placebo_tunessim_crf
for /L %%i in (55,-5,25) do call %benchmark_bat% -codec libvpx -i "%~1" -o "%~n1_libvpx_vp9_c0_2pass_q%%i.webm" -cmd "--codec=vp9 --frame-parallel=0 --tile-columns=2 --good --cpu-used=0 --tune=psnr --passes=2 --threads=2 --end-usage=q --cq-level=%%i --webm --auto-alt-ref=6 --kf-max-dist=250" -csv vp9_c0_2pass_q
for /L %%i in (55,-5,25) do call %benchmark_bat% -codec libaom -i "%~1" -o "%~n1_libaom_c0_2pass_q%%i.mp4" -cmd "--ivf --cpu-used=0 --threads=8 --tile-columns=2 --tile-rows=2 --passes=2 --end-usage=q --cq-level=%%i --kf-max-dist=250" -csv c0_2pass_q
rem 10bit sample
rem for /L %%i in (50,-2,30) do call %benchmark_bat% -codec SVT-AV1 -i "%~1" -o "%~n1_SVT-AV1_10bit_e0_q%%i.mp4" -cmd "-enc-mode 0 -q %%i -bit-depth 10" -csv 10bit_e0 -encode-depth 10
rem for /L %%i in (32,-2,18) do call %benchmark_bat% -codec x264 -i "%~1" -o "%~n1_x264_10bit_placebo_tunessim_crf%%i.mp4" -cmd "--preset placebo --tune ssim --crf %%i --input-depth 10 --output-depth 10" -csv 10bit_placebo_tunessim_crf -encode-depth 10
rem for /L %%i in (32,-2,18) do call %benchmark_bat% -codec x265 -i "%~1" -o "%~n1_x265_10bit_placebo_tunessim_crf%%i.mp4" -cmd "--preset placebo --tune ssim --crf %%i --input-depth 10 --output-depth 10" -csv 10bit_placebo_tunessim_crf -encode-depth 10
rem for /L %%i in (55,-5,25) do call %benchmark_bat% -codec libaom -i "%~1" -o "%~n1_libaom_10bit_c0_2pass_q%%i.mp4" -cmd "--ivf --cpu-used=0 --threads=8 --tile-columns=2 --tile-rows=2 --passes=2 --end-usage=q --cq-level=%%i --kf-max-dist=250 --input-bit-depth=10 --bit-depth=10" -csv 10bit_c0_2pass_q -encode-depth 10
shift
goto loop
:end
exit /b
