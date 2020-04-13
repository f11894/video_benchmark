@echo off
for %%i in ("%~dp0.") do set benchmark_bat="%%~dpivideo_benchmark.bat"
:loop
if "%~1"=="" goto end
for /L %%i in (160,-20,60) do call %benchmark_bat% -codec rav1e -i "%~1" -o "%~n1_rav1e_20190921_s2_tunepsnr_1pass_q%%i.mp4" -cmd "--quantizer %%i --speed 2 --tune psnr --keyint 250 --threads 8 --tile-cols 2 --tile-rows 2" -csvsuf 20190921_s2_tunepsnr_1pass_q
for /L %%i in (32,-2,18) do call %benchmark_bat% -codec x264 -i "%~1" -o "%~n1_x264_veryslow_tunessim_crf%%i.mp4" -cmd "--preset veryslow --tune ssim --keyint 250 --crf %%i" -csvsuf veryslow_tunessim_crf
for /L %%i in (32,-2,18) do call %benchmark_bat% -codec x265 -i "%~1" -o "%~n1_x265_veryslow_tunessim_crf%%i.mp4" -cmd "--preset veryslow --tune ssim --keyint 250 --crf %%i" -csvsuf veryslow_tunessim_crf
for /L %%i in (55,-5,25) do call %benchmark_bat% -codec libvpx -i "%~1" -o "%~n1_libvpx_vp9_c0_2pass_q%%i.webm" -cmd "--codec=vp9 --webm --good --cpu-used=0 --tune=psnr --threads=8 --tile-columns=2 --tile-rows=2 --pass=2 --passes=2 --auto-alt-ref=6 --kf-max-dist=250 --end-usage=q --cq-level=%%i " -csvsuf vp9_c0_2pass_q
for /L %%i in (55,-5,25) do call %benchmark_bat% -codec libaom -i "%~1" -o "%~n1_libaom_c1_2pass_q%%i.mp4" -cmd "--ivf --cpu-used=1 --threads=8 --tile-columns=2 --tile-rows=2 --pass=2 --passes=2 --kf-max-dist=250 --end-usage=q --cq-level=%%i" -csvsuf c1_2pass_q
rem 10bit example
rem for /L %%i in (50,-2,30) do call %benchmark_bat% -codec SVT-AV1 -i "%~1" -o "%~n1_SVT-AV1_10bit_e0_q%%i.mp4" -cmd "-enc-mode 0 -q %%i -bit-depth 10" -csvsuf 10bit_e0 -encode-depth 10
rem for /L %%i in (32,-2,18) do call %benchmark_bat% -codec x264 -i "%~1" -o "%~n1_x264_10bit_veryslow_tunessim_crf%%i.mp4" -cmd "--preset veryslow --tune ssim --crf %%i --input-depth 10 --output-depth 10" -csvsuf 10bit_veryslow_tunessim_crf -encode-depth 10
rem for /L %%i in (32,-2,18) do call %benchmark_bat% -codec x265 -i "%~1" -o "%~n1_x265_10bit_veryslow_tunessim_crf%%i.mp4" -cmd "--preset veryslow --tune ssim --crf %%i --input-depth 10 --output-depth 10" -csvsuf 10bit_veryslow_tunessim_crf -encode-depth 10
rem for /L %%i in (55,-5,25) do call %benchmark_bat% -codec libaom -i "%~1" -o "%~n1_libaom_10bit_c0_2pass_q%%i.mp4" -cmd "--ivf --cpu-used=0 --threads=8 --tile-columns=2 --tile-rows=2 --pass=2 --passes=2 --end-usage=q --cq-level=%%i --kf-max-dist=250 --input-bit-depth=10 --bit-depth=10" -csvsuf 10bit_c0_2pass_q -encode-depth 10
shift
goto loop
:end
exit /b
