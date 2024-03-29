@echo off
for %%i in ("%~dp0.") do set benchmark_bat="%%~dpivideo_benchmark.bat"

for %%i in ("%~dp0.") do set busybox64="%%~dpitools\busybox64.exe"
for %%i in ("%~dp0.") do set ffmpeg="%%~dpitools\ffmpeg.exe"
for %%i in ("%~dp0.") do set timer64="%%~dpitools\timer64.exe"
for %%i in ("%~dp0.") do set view_args64="%%~dpitools\view_args64.exe"
for %%i in ("%~dp0.") do set VTMenc="%%~dpitools\vtm\EncoderApp.exe"
for %%i in ("%~dp0.") do set "VTM_cfg=%%~dpitools\vtm\cfg\encoder_randomaccess_vtm.cfg"

set ComparePixelFormat=-pix_fmt yuv420p10le
set VTM_option="-c %VTM_cfg% --InputBitDepth=10 --OutputBitDepth=10 --IntraPeriod=256 -q %%i"
set thread=8

for %%i in ("%~dp0.") do pushd "%%~dpitools\"
set xargs_txt="%TEMP%\xargs_%RANDOM%_%RANDOM%_%RANDOM%.txt"
setlocal enabledelayedexpansion
for %%f in (%*) do (
   FOR /f "DELIMS=" %%i IN ('.\ffprobe.exe -v error -select_streams v:0 -show_entries stream^=width -of default^=noprint_wrappers^=1:nokey^=1 "%%~f"') DO SET "Width_delay=%%i"
   FOR /f "DELIMS=" %%i IN ('.\ffprobe.exe -v error -select_streams v:0 -show_entries stream^=height -of default^=noprint_wrappers^=1:nokey^=1 "%%~f"') DO SET "Height_delay=%%i"
   FOR /f "DELIMS=" %%i IN ('.\ffprobe.exe -v error -count_frames -select_streams v:0 -show_entries stream^=nb_read_frames -of default^=nokey^=1:noprint_wrappers^=1 "%%~f"') DO SET "FrameCount_delay=%%i"
   FOR /f "DELIMS=" %%a IN ('.\ffmpeg.exe -loglevel 48 -i "%%~f" -t 00:00:00.00 -vcodec rawvideo -an -f null -  2^>^&1 ^| find "'frame_rate'"') DO SET frame_rate_delay=%%a
   FOR /f "tokens=4 DELIMS='" %%a IN ("!frame_rate_delay!") DO SET frame_rate_delay=%%a
   FOR /f "tokens=1 DELIMS=/" %%a IN ("!frame_rate_delay!") DO SET frame_rate_num_delay=%%a
   rem FOR /f "tokens=2 DELIMS=/" %%a IN ("!frame_rate_delay!") DO SET frame_rate_denom_delay=%%a
   set frame_rate_integer_delay=!frame_rate_num_delay!
   if "!frame_rate_delay!"=="60000/1001" set frame_rate_integer_delay=60
   if "!frame_rate_delay!"=="30000/1001" set frame_rate_integer_delay=30
   if "!frame_rate_delay!"=="24000/1001" set frame_rate_integer_delay=24
   if not exist "%%~dpf%%~nf_benchmark_log\" mkdir "%%~dpf%%~nf_benchmark_log\"
   for /L %%i in (36,-2,22) do (
      echo "%%~f" "VTM_10bit_q%%i" %VTM_option% !Width_delay! !Height_delay! !FrameCount_delay! !frame_rate_delay! !frame_rate_integer_delay!>>%xargs_txt%
      if not exist "%%~dpnf_temp10bit.yuv" %view_args64% %ffmpeg% -y -i "%%~f" -an -pix_fmt yuv420p10le -f rawvideo -strict -2 "%%~dpnf_temp10bit.yuv" >"%%~dpf%%~nf_benchmark_log\%%~nf_VTM_10bit_q%%i_log.txt" 2>&1 
   )
)
endlocal
popd

%busybox64% xargs -a %xargs_txt%  -n 8 -P %thread% "%~dp0VTM_xargs.bat"
:loop
if "%~1"=="" goto end
for /L %%i in (36,-2,22) do call %benchmark_bat% -codec VTM -i "%~1" -o "%~n1_VTM_10bit_q%%i.bin" -cmd %VTM_option% -csvsuf 10bit_q -encode-depth 10
rem For comparison
for /L %%i in (32,-2,18) do call %benchmark_bat% -codec x264 -i "%~1" -o "%~n1_x264_10bit_placebo_tunessim_kf256_crf%%i.mp4" -cmd "--preset placebo --tune ssim --keyint 256 --crf %%i --input-depth 10 --output-depth 10" -csvsuf 10bit_placebo_tunessim_kf256_crf -encode-depth 10
for /L %%i in (32,-2,18) do call %benchmark_bat% -codec x265 -i "%~1" -o "%~n1_x265_10bit_placebo_tunessim_kf256_crf%%i.mp4" -cmd "--preset placebo --tune ssim --keyint 256 --crf %%i --input-depth 10 --output-depth 10" -csvsuf 10bit_placebo_tunessim_kf256_crf -encode-depth 10
for /L %%i in (55,-5,25) do call %benchmark_bat% -codec libvpx -i "%~1" -o "%~n1_libvpx_vp9_10bit_c0_kf256_2pass_q%%i.webm" -cmd "--codec=vp9 --webm --good --profile=2 --cpu-used=0 --tune=psnr --threads=8 --tile-columns=2 --tile-rows=1 --pass=2 --passes=2 --auto-alt-ref=6 --kf-max-dist=256 --lag-in-frames=25 --end-usage=q --cq-level=%%i --input-bit-depth=10 --bit-depth=10" -csvsuf 10bit_vp9_c0_kf256_2pass_q -encode-depth 10
for /L %%i in (55,-5,25) do call %benchmark_bat% -codec libaom -i "%~1" -o "%~n1_libaom_10bit_c0_kf256_2pass_q%%i.mp4" -cmd "--ivf --cpu-used=0 --threads=8 --tile-columns=2 --tile-rows=1 --pass=2 --passes=2 --kf-max-dist=256 --lag-in-frames=25 --end-usage=q --cq-level=%%i --input-bit-depth=10 --bit-depth=10" -csvsuf 10bit_c0_kf256_2pass_q -encode-depth 10
shift
goto loop
:end
exit /b
