@echo off
rem setting
rem ------------------------------------------------------------------------------------------------
rem How much higher is the QP of P frame and B frame higher than I frame in cqp and vqp mode of QSV
set QP_p_n=2
set QP_b_n=5

rem Delete the encoded file (1: on)
set del_enc_file=0

rem How many seconds to wait when an error occurs
set wait=60

rem Bit depth when calculating SSIM or VMAF
set ComparePixelFormat=-pix_fmt yuv420p

rem Soft path
set ffmpeg="%~dp0tools\ffmpeg.exe"
if "%ffmpeg_enc%"=="" set ffmpeg_enc=%ffmpeg%
set ffmpeg_VMAF="%~dp0tools\ffmpeg_vmaf.exe"
set mediaInfo="%~dp0tools\MediaInfo.exe"
set timer64="%~dp0tools\timer64.exe"
set view_args64="%~dp0tools\view_args64.exe"
set safetee="%~dp0tools\safetee.exe"
set busybox64="%~dp0tools\busybox64.exe"
set x264="%~dp0tools\x264.exe"
set x265="%~dp0tools\x265.exe"
set QSVEncC="%~dp0tools\QSVEncC\x64\QSVEncC64.exe"
set VCEEncC="%~dp0tools\VCEEncC\x64\VCEEncC64.exe"
set NVEncC="%~dp0tools\VCEEncC\x64\NVEncC64.exe"
set vpxenc="%~dp0tools\vpxenc.exe"
set aomenc="%~dp0tools\aomenc.exe"
set rav1e="%~dp0tools\rav1e.exe"
set SVT-AV1="%~dp0tools\SvtAv1EncApp.exe"
set SVT-VP9="%~dp0tools\SvtVp9EncApp.exe"
set SVT-HEVC="%~dp0tools\SvtHevcEncApp.exe"
set VTMenc="%~dp0tools\vtm\EncoderApp.exe"
set VTMdec="%~dp0tools\vtm\DecoderApp.exe"
set xvcenc="%~dp0tools\xvcenc.exe"
set xvcdec="%~dp0tools\xvcdec.exe"
set mp4box="%~dp0tools\mp4box.exe"
rem ------------------------------------------------------------------------------------------------
if "%language_configured%"=="1" goto ArgumentCheck
for /f "tokens=2" %%i in ('PowerShell Get-WinSystemLocale') do set "SystemLocale=%%i"
chcp 65001 >nul 2>&1
call "%~dp0language\UILang.en-US.bat"
if exist "%~dp0language\UIlang.%SystemLocale%.bat" call "%~dp0language\UIlang.%SystemLocale%.bat"
set language_configured=1

:ArgumentCheck
rem 引数チェック
set "EncodeBitDepth=8"
set ArgumentError=
call :variable_set -cmd CommandLine_orig %*
call :variable_set -i InputVideo %*
call :variable_set -o OutputVideo %*
call :variable_set -csvsuf CsvNameSuffix %*
call :variable_set -codec codec %*
echo "%*"|find "-encode-depth" >nul&& call :variable_set -encode-depth EncodeBitDepth %*
if "%codec%"=="" set ArgumentError=1
if "%InputVideo%"=="" set ArgumentError=1
if "%OutputVideo%"=="" set ArgumentError=1
if "%CommandLine_orig%"=="" set ArgumentError=1
if "%ArgumentError%"=="1" (
   echo %MessageArgumentErrorLine1%
   echo %MessageArgumentErrorLine2%
   timeout /t 30
   exit /b
)
for %%i in ("%InputVideo%") do set "InputVideoNoExt=%%~ni"
for %%i in ("%InputVideo%") do set "InputVideo=%%~dpnxi"
for %%i in ("%OutputVideo%") do set "OutputVideoNoExt=%%~ni"
if defined CsvNameSuffix set "CsvNameSuffix=_%CsvNameSuffix%"

for %%i in ("%OutputVideo%") do set "movie_dir=%%~dpi"
for %%i in ("%OutputVideo%") do set "OutputVideo=%%~nxi"
set "log_dir=%movie_dir%\%InputVideoNoExt%_benchmark_log\"
set error_log="%log_dir%%InputVideoNoExt%__error_log.txt"

rem 動画の情報を調べる
:ffmediaInfo
if not exist "%log_dir%" mkdir "%log_dir%"
if not exist "%movie_dir%" mkdir "%movie_dir%"
if "%ffmediaInfo_file%"=="%InputVideo%" goto start
echo %MessageInputVideoCheck%

call "%~dp0ffmediaInfo.bat" "%InputVideo%"

if "%Duration%"=="" if "%FrameCount%"=="" (
   echo %MessageInputVideoCheckError%
   echo.
   timeout /t %wait%
   goto input_error_skip
)
set Duration_msec=%Duration:~9,3%
set /a Duration_msec=1%Duration_msec%-1000
set Duration_sec=%Duration:~6,2%
set /a Duration_sec=(1%Duration_sec%-100)*1000
set Duration_Minute=%Duration:~3,2%
set /a Duration_Minute=(1%Duration_Minute%-100)*60000
set Duration_Hour=%Duration:~0,2%
set /a Duration_Hour=(1%Duration_Hour%-100)*3600000
set /a Duration2=%Duration_msec%+%Duration_sec%+%Duration_Minute%+%Duration_Hour%
call echo %MessageInputVideoInfoFileName%
call echo %MessageInputVideoInfoVideoSize%
call echo %MessageInputVideoInfoFrameRate%
call echo %MessageInputVideoInfoFrameCount%
call echo %MessageInputVideoInfoDuration%
echo.
set "ffmediaInfo_file=%InputVideo%"

:start
setlocal

pushd "%movie_dir%"

:enc_process
rem エンコード前の下処理
set "CommandLine=%CommandLine_orig%"
set "CsvName=%codec%%CsvNameSuffix%"
set "CompareBitDepth=Unspecified"
echo "%ComparePixelFormat%"|find "yuv420p" >nul&&set "CompareBitDepth=8bit"
echo "%ComparePixelFormat%"|find "yuv420p10le" >nul&&set "CompareBitDepth=10bit"
set "EncodePixelFormat=-pix_fmt yuv420p"
if "%EncodeBitDepth%"=="10" (
   set "EncodePixelFormat=-pix_fmt yuv420p10le"
)

rem qsv_enc用前処理
echo "%codec%"|findstr "QSVEncC VCEEncC" >nul&& echo "%CommandLine%"|findstr /r /c:"--cqp [0-9]">nul&&call :variable_set --cqp QSVQP %CommandLine%
echo "%codec%"|findstr "QSVEncC VCEEncC" >nul&& echo "%CommandLine%"|findstr /r /c:"--vqp [0-9]">nul&&call :variable_set --vqp QSVQP %CommandLine%
set /a QP_p=%QSVQP%+%QP_p_n%
set /a QP_b=%QSVQP%+%QP_b_n%
echo "%codec%"|findstr "QSVEncC VCEEncC" >nul&& echo "%CommandLine%"|findstr /r /c:"--cqp [0-9]">nul&&call set "CommandLine=%%CommandLine:--cqp %QSVQP%=--cqp %QSVQP%:%QP_p%:%QP_b%%%"
echo "%codec%"|findstr "QSVEncC VCEEncC" >nul&& echo "%CommandLine%"|findstr /r /c:"--vqp [0-9]">nul&&call set "CommandLine=%%CommandLine:--vqp %QSVQP%=--vqp %QSVQP%:%QP_p%:%QP_b%%%"

rem マルチパス用の処理
if not "%multipass%"=="1" echo "%CommandLine%"|find "--second-pass">nul&&set multipass=1&&set pass_temp=1&&set pass_orig=2&&set "CommandLine=%CommandLine:--second-pass=--first-pass%"
if not "%multipass%"=="1" echo "%CommandLine%"|findstr /r /c:"--pass=[0-9]">nul&&set "multipasstype=1"&&call :pass_number_set --pass
if not "%multipass%"=="1" echo "%CommandLine%"|findstr /r /c:"--pass [0-9]">nul&&set "multipasstype=0"&&call :pass_number_set --pass
if not "%multipass%"=="1" echo "%CommandLine%"|findstr /r /c:"-pass [0-9]">nul&&set "multipasstype=0"&&call :pass_number_set -pass
if not "%codec%"=="rav1e" if "%multipass%"=="1" call :multi_pass_set
rem 各エンコーダーでエンコード
if not exist "%movie_dir%%OutputVideo%" (
   rem ログフォルダに以前のログが残っていたら削除する
   if exist "%log_dir%%OutputVideoNoExt%_ssim(%CompareBitDepth%)_log%pass_orig%.txt" del "%log_dir%%OutputVideoNoExt%_ssim(%CompareBitDepth%)_log%pass_orig%.txt"
   if exist "%log_dir%%OutputVideoNoExt%_vmaf(%CompareBitDepth%)_log%pass_orig%.txt" del "%log_dir%%OutputVideoNoExt%_vmaf(%CompareBitDepth%)_log%pass_orig%.txt"

   if "%multipass%"=="1" echo %MessageMultiPass% %pass_temp%/%pass_orig%&&echo.
   if /i "%codec%"=="QSVEncC" %timer64% "%QSVEncC%" -i "%InputVideo%" %CommandLine% -o "%movie_dir%%OutputVideo%" 2>&1 | %safetee% -o "%log_dir%%OutputVideoNoExt%_log%pass_temp%.txt"
   if /i "%codec%"=="VCEEncC" %timer64% "%VCEEncC%" -i "%InputVideo%" %CommandLine% -o "%movie_dir%%OutputVideo%" 2>&1 | %safetee% -o "%log_dir%%OutputVideoNoExt%_log%pass_temp%.txt"
   if /i "%codec%"=="NVEncC" %timer64% "%NVEncC%" -i "%InputVideo%" %CommandLine% -o "%movie_dir%%OutputVideo%" 2>&1 | %safetee% -o "%log_dir%%OutputVideoNoExt%_log%pass_temp%.txt"
   if /i "%codec%"=="FFmpeg" %timer64% %ffmpeg_enc% -y -i "%InputVideo%" -an %EncodePixelFormat% %CommandLine% "%movie_dir%%OutputVideo%" 2>&1 | %safetee% -o "%log_dir%%OutputVideoNoExt%_log%pass_temp%.txt"
   if /i "%codec%"=="x264" %view_args64% %ffmpeg% -y -i "%InputVideo%" -an %EncodePixelFormat% -strict -2 -f yuv4mpegpipe - 2>"%log_dir%%OutputVideoNoExt%_pipelog%pass_temp%.txt" | %timer64% %x264% %CommandLine% --demuxer y4m -o "%movie_dir%%OutputVideo%" - 2>&1 | %safetee% -o "%log_dir%%OutputVideoNoExt%_log%pass_temp%.txt"
   if /i "%codec%"=="x265" %view_args64% %ffmpeg% -y -i "%InputVideo%" -an %EncodePixelFormat% -strict -2 -f yuv4mpegpipe - 2>"%log_dir%%OutputVideoNoExt%_pipelog%pass_temp%.txt" | %timer64% %x265% %CommandLine% --input - --y4m "%movie_dir%%OutputVideoNoExt%.h265" 2>&1 | %safetee% -o "%log_dir%%OutputVideoNoExt%_log%pass_temp%.txt"
   if /i "%codec%"=="libaom" (
      %aomenc% --help | find "AOMedia Project AV1 Encoder">>"%log_dir%%OutputVideoNoExt%_log%pass_temp%.txt" 2>&1 
      %view_args64% %ffmpeg% -y -i "%InputVideo%" -an %EncodePixelFormat% -strict -2 -f yuv4mpegpipe - 2>"%log_dir%%OutputVideoNoExt%_pipelog%pass_temp%.txt" | %timer64% %aomenc% %CommandLine% -o "%movie_dir%%OutputVideoNoExt%.ivf" - 2>&1 | %safetee% -a "%log_dir%%OutputVideoNoExt%_log%pass_temp%.txt"
   )
   if /i "%codec%"=="rav1e" (
      %rav1e% --version >"%log_dir%%OutputVideoNoExt%_log%pass_temp%.txt"
      %view_args64% %ffmpeg% -y -i "%InputVideo%" -an %EncodePixelFormat% -strict -2 -f yuv4mpegpipe - 2>"%log_dir%%OutputVideoNoExt%_pipelog%pass_temp%.txt" | %timer64% %rav1e% - %CommandLine% -o "%movie_dir%%OutputVideoNoExt%.ivf" 2>&1 | %safetee% -a "%log_dir%%OutputVideoNoExt%_log%pass_temp%.txt"
   )
   if /i "%codec%"=="SVT-AV1" %view_args64% %ffmpeg% -y -i "%InputVideo%" -an -nostdin -f rawvideo %EncodePixelFormat% -strict -2 - 2>"%log_dir%%OutputVideoNoExt%_pipelog%pass_temp%.txt" | %timer64% %SVT-AV1% -i stdin %CommandLine% -n %FrameCount% -w %Width% -h %Height% -fps-num %frame_rate_num% -fps-denom %frame_rate_denom% -b "%movie_dir%%OutputVideoNoExt%.ivf" 2>&1 | %safetee% -o "%log_dir%%OutputVideoNoExt%_log%pass_temp%.txt"
   if /i "%codec%"=="SVT-HEVC" %view_args64% %ffmpeg% -y -i "%InputVideo%" -an -nostdin -f rawvideo %EncodePixelFormat% -strict -2 - 2>"%log_dir%%OutputVideoNoExt%_pipelog%pass_temp%.txt" | %timer64% %SVT-HEVC% -i stdin %CommandLine% -n %FrameCount% -w %Width% -h %Height% -fps-num %frame_rate_num% -fps-denom %frame_rate_denom% -b "%movie_dir%%OutputVideoNoExt%.h265" 2>&1 | %safetee% -o "%log_dir%%OutputVideoNoExt%_log%pass_temp%.txt"
   if /i "%codec%"=="SVT-VP9" %view_args64% %ffmpeg% -y -i "%InputVideo%" -an -nostdin -f rawvideo %EncodePixelFormat% -strict -2 - 2>"%log_dir%%OutputVideoNoExt%_pipelog%pass_temp%.txt" | %timer64% %SVT-VP9% -i stdin %CommandLine% -n %FrameCount% -w %Width% -h %Height% -fps-num %frame_rate_num% -fps-denom %frame_rate_denom% -b "%movie_dir%%OutputVideoNoExt%.ivf" 2>&1 | %safetee% -o "%log_dir%%OutputVideoNoExt%_log%pass_temp%.txt"
   if /i "%codec%"=="libvpx" (
      %vpxenc% --help | find "WebM Project">>"%log_dir%%OutputVideoNoExt%_log%pass_temp%.txt" 2>&1 
      %view_args64% %ffmpeg% -y -i "%InputVideo%" -an %EncodePixelFormat% -strict -2 -f yuv4mpegpipe - 2>"%log_dir%%OutputVideoNoExt%_pipelog%pass_temp%.txt" | %timer64% %vpxenc% %CommandLine% -o "%movie_dir%%OutputVideo%" - 2>&1 | %safetee% -a "%log_dir%%OutputVideoNoExt%_log%pass_temp%.txt"
   )
   if /i "%codec%"=="VTM" (
       if not exist "%movie_dir%%InputVideoNoExt%_temp%EncodeBitDepth%bit.yuv" echo %MessageIntermediateFileEncode% && %view_args64% %ffmpeg% -i "%InputVideo%" -an %EncodePixelFormat% -f rawvideo -strict -2 "%movie_dir%%InputVideoNoExt%_temp%EncodeBitDepth%bit.yuv" >"%log_dir%%OutputVideoNoExt%_log%pass_temp%.txt" 2>&1
       %timer64% %VTMenc%  %CommandLine% -fr %frame_rate_integer% -wdt %Width% -hgt %Height% -f %FrameCount% -i "%movie_dir%%InputVideoNoExt%_temp%EncodeBitDepth%bit.yuv" -o NUL -b "%movie_dir%%OutputVideo%" 2>&1 | %safetee% -a "%log_dir%%OutputVideoNoExt%_log%pass_temp%.txt"
   )
   if /i "%codec%"=="xvc" (
       %view_args64% %ffmpeg% -y -i "%InputVideo%" -an %EncodePixelFormat% -strict -2 -f yuv4mpegpipe - 2>"%log_dir%%OutputVideoNoExt%_pipelog%pass_temp%.txt" | %timer64% %xvcenc% -verbose 1 -input-file - -output-file "%movie_dir%%OutputVideo%" %CommandLine% 2>&1 | %safetee% -a "%log_dir%%OutputVideoNoExt%_log%pass_temp%.txt"
   )
) else (
   set enc_skip=1
   echo %MessageEncodeSkip%
)

rem エンコード後の処理
echo.
rem エラーチェック&マルチパスの途中のファイルは削除する
set ErrorCheckFile="%movie_dir%%OutputVideo%"
if /i "%codec%"=="x265" set ErrorCheckFile="%movie_dir%%OutputVideoNoExt%.h265"
if /i "%codec%"=="SVT-HEVC" set ErrorCheckFile="%movie_dir%%OutputVideoNoExt%.h265"
if /i "%codec%"=="rav1e" set ErrorCheckFile="%movie_dir%%OutputVideoNoExt%.ivf"
if /i "%codec%"=="libaom" set ErrorCheckFile="%movie_dir%%OutputVideoNoExt%.ivf"
if /i "%codec%"=="SVT-AV1" set ErrorCheckFile="%movie_dir%%OutputVideoNoExt%.ivf"
if /i "%codec%"=="SVT-VP9" set ErrorCheckFile="%movie_dir%%OutputVideoNoExt%.ivf"

if not "%enc_skip%"=="1" (
    if /i "%codec%"=="libvpx" if "%multipass%"=="1" goto ErrorCheckSkip
    if /i "%codec%"=="libaom" if "%multipass%"=="1" goto ErrorCheckSkip
    call :error_check "%InputVideo%" %ErrorCheckFile%
)
:ErrorCheckSkip
if "%multipass%"=="1" if not "%enc_skip%"=="1" if not "%pass_temp%"=="%pass_orig%" if exist %ErrorCheckFile% del %ErrorCheckFile%

rem そのままではFFmpegで扱えないビットストリームを可逆圧縮のH.264にデコードする
if not "%enc_error%"=="1" if not exist "%movie_dir%%OutputVideoNoExt%.mp4" (
   if /i "%codec%"=="VTM" (
      %VTMdec% -d %EncodeBitDepth% -b "%movie_dir%%OutputVideo%" -o "%movie_dir%%OutputVideoNoExt%.yuv" 2>&1 | %safetee% -a "%log_dir%%OutputVideoNoExt%_log%pass_temp%.txt"
      %view_args64% %ffmpeg% -y -f rawvideo -s %video_size% -r %frame_rate% %EncodePixelFormat% -i "%movie_dir%%OutputVideoNoExt%.yuv" -vcodec libx264 -qp 0 "%movie_dir%%OutputVideoNoExt%.mp4" >>"%log_dir%%OutputVideoNoExt%_log%pass_temp%.txt" 2>&1 &&del "%movie_dir%%OutputVideoNoExt%.yuv"
   )
   if /i "%codec%"=="xvc" (
      %xvcdec% -bitstream-file "%movie_dir%%OutputVideo%" -output-file "%movie_dir%%OutputVideoNoExt%.yuv" 2>&1 | %safetee% -a "%log_dir%%OutputVideoNoExt%_log%pass_temp%.txt"
      %view_args64% %ffmpeg% -y -f rawvideo -s %video_size% -r %frame_rate% %EncodePixelFormat% -i "%movie_dir%%OutputVideoNoExt%.yuv" -vcodec libx264 -qp 0 "%movie_dir%%OutputVideoNoExt%.mp4" >>"%log_dir%%OutputVideoNoExt%_log%pass_temp%.txt" 2>&1 &&del "%movie_dir%%OutputVideoNoExt%.yuv"
   )
)

rem 処理時間をログファイルから拾う
if not "%enc_error%"=="1" find "TotalMilliseconds : " "%log_dir%%OutputVideoNoExt%_log%pass_temp%.txt">nul 2>&1||set timer_error=1&&SET enc_msec%pass_temp%=0
if not "%enc_error%"=="1" if not "%timer_error%"=="1" FOR /f "tokens=3" %%i IN ('find "TotalMilliseconds : " "%log_dir%%OutputVideoNoExt%_log%pass_temp%.txt"') DO SET enc_msec%pass_temp%=%%i
if not "%enc_error%"=="1" call :msec_to_sec
rem マルチパスなら最終パスになるまで処理をループする
if "%multipass%"=="1" if not "%pass_temp%"=="%pass_orig%" (
   if /i "%codec%"=="rav1e" set "CommandLine=%CommandLine:--first-pass=--second-pass%"
   set /a pass_temp=pass_temp+1
   goto enc_process
)
if "%multipass%"=="1" (
   if exist ffmpeg2pass-0.log del ffmpeg2pass-0.log
   if exist ffmpeg2pass-0.log.mbtree del ffmpeg2pass-0.log.mbtree
   if exist x264_2pass.log del x264_2pass.log
   if exist x264_2pass.log.mbtree del x264_2pass.log.mbtree
   if exist x265_2pass.log del x265_2pass.log
   if exist x265_2pass.log.cutree del x265_2pass.log.cutree
   if exist rav1e_stats.json del rav1e_stats.json
   if exist rav1e_stats.log del rav1e_stats.log
   if exist temp.fpf del temp.fpf
)
rem rawファイルをコンテナに格納
if not "%enc_skip%"=="1" if exist "%movie_dir%%OutputVideoNoExt%.h265" %view_args64% %mp4box% -fps %frame_rate_mp4box% -add "%movie_dir%%OutputVideoNoExt%.h265" -new "%movie_dir%%OutputVideo%" >>"%log_dir%%OutputVideoNoExt%_log%pass_temp%.txt" 2>&1 && del "%movie_dir%%OutputVideoNoExt%.h265" & echo.
if not "%enc_skip%"=="1" if exist "%movie_dir%%OutputVideoNoExt%.ivf" (
   if /i "%codec%"=="SVT-VP9" (
      %view_args64% %ffmpeg% -y -r %frame_rate% -i "%movie_dir%%OutputVideoNoExt%.ivf" -c copy "%movie_dir%%OutputVideo%" >>"%log_dir%%OutputVideoNoExt%_log%pass_temp%.txt" 2>&1 && del "%movie_dir%%OutputVideoNoExt%.ivf"
   ) else (
      %view_args64% %mp4box% -fps %frame_rate_mp4box% -add "%movie_dir%%OutputVideoNoExt%.ivf" -new "%movie_dir%%OutputVideo%" >>"%log_dir%%OutputVideoNoExt%_log%pass_temp%.txt" 2>&1 && del "%movie_dir%%OutputVideoNoExt%.ivf"
   )
   echo.
)
chcp 65001 >nul 2>&1

rem SSIMを算出する
for %%i in ("%movie_dir%%OutputVideo%") do set Filesize=%%~zi
set ffmpeg_ssim_option="ssim='%OutputVideoNoExt%_ssim(%CompareBitDepth%)_verbose_log.txt';[0:v][1:v]psnr='%OutputVideoNoExt%_psnr(%CompareBitDepth%)_verbose_log.txt'"
popd
pushd "%log_dir%"

set CompareVideo="%movie_dir%%OutputVideo%"
if /i "%codec%"=="VTM" set CompareVideo="%movie_dir%%OutputVideoNoExt%.mp4"
if /i "%codec%"=="xvc" set CompareVideo="%movie_dir%%OutputVideoNoExt%.mp4"

find "Parsed_ssim" "%OutputVideoNoExt%_ssim(%CompareBitDepth%)_log%pass_orig%.txt">nul 2>&1 || set SSIM_check=1
if not exist "%log_dir%%OutputVideoNoExt%_ssim(%CompareBitDepth%)_verbose_log.txt" set SSIM_check=1
if not exist "%log_dir%%OutputVideoNoExt%_psnr(%CompareBitDepth%)_verbose_log.txt" set SSIM_check=1

if "%SSIM_check%"=="1" if not "%enc_error%"=="1" (
   call echo %MessageSSIMCompare%
   echo %MessagePleaseWait%
   %view_args64% %ffmpeg% -r %frame_rate% -i %CompareVideo% -an %ComparePixelFormat% -strict -2 -f yuv4mpegpipe - 2>"%OutputVideoNoExt%_ssim(%CompareBitDepth%)_pipelog%pass_orig%.txt" | %view_args64% %ffmpeg% -i - -r %frame_rate% -i "%InputVideo%" -lavfi %ffmpeg_ssim_option% -an -f null - >"%OutputVideoNoExt%_ssim(%CompareBitDepth%)_log%pass_orig%.txt" 2>&1
   echo.
)
find "Parsed_ssim" "%OutputVideoNoExt%_ssim(%CompareBitDepth%)_log%pass_orig%.txt">nul 2>&1
if not "%ERRORLEVEL%"=="0" if not "%enc_error%"=="1" (
   echo %MessageSSIMCompareError%
   echo %date% %time%>>%error_log%
   echo %MessageSSIMCompareError% >>%error_log%
   echo Input video>>%error_log%
   echo "%InputVideo%">>%error_log%
   echo Comparison video>>%error_log%
   echo "%movie_dir%%OutputVideo%">>%error_log%
   echo.>>%error_log%
   set Compare_error=1
   echo.
   timeout /T %wait%
)
popd

set "vmaf_model_file=vmaf_v0.6.1.pkl"
if %Height% GTR 2000 set "vmaf_model_file=vmaf_4k_v0.6.1.pkl"
for %%i in (%ffmpeg_VMAF%) do set "vmaf_model_dir=%%~dpi\model"
pushd %vmaf_model_dir%
set ffmpeg_vmaf_option="libvmaf=model_path=%vmaf_model_file%:ms_ssim=1:log_fmt=json:log_path='%OutputVideoNoExt%_vmaf(%CompareBitDepth%).json'"

find "VMAF score" "%log_dir%%OutputVideoNoExt%_vmaf(%CompareBitDepth%)_log%pass_orig%.txt">nul 2>&1 || set VMAF_check=1
find "MS-SSIM score" "%log_dir%%OutputVideoNoExt%_vmaf(%CompareBitDepth%)_log%pass_orig%.txt">nul 2>&1 || set VMAF_check=1
if not exist "%log_dir%%OutputVideoNoExt%_vmaf(%CompareBitDepth%).json" set VMAF_check=1

if "%VMAF_check%"=="1" if not "%enc_error%"=="1" (
   call echo %MessageVMAFCompare%
   echo %MessagePleaseWait%
   %view_args64% %ffmpeg% -r %frame_rate% -i %CompareVideo% -an %ComparePixelFormat% -strict -2 -f yuv4mpegpipe - 2>"%log_dir%%OutputVideoNoExt%_vmaf(%CompareBitDepth%)_pipelog%pass_orig%.txt" | %view_args64% %ffmpeg_VMAF% -i - -r %frame_rate% -i "%InputVideo%" -filter_complex %ffmpeg_vmaf_option% -an -f null - >"%log_dir%%OutputVideoNoExt%_vmaf(%CompareBitDepth%)_log%pass_orig%.txt" 2>&1
   echo.
)
if exist "%OutputVideoNoExt%_vmaf(%CompareBitDepth%).json" move /Y "%OutputVideoNoExt%_vmaf(%CompareBitDepth%).json" "%log_dir%%OutputVideoNoExt%_vmaf(%CompareBitDepth%).json" >nul
find "VMAF score" "%log_dir%%OutputVideoNoExt%_vmaf(%CompareBitDepth%)_log%pass_orig%.txt">nul 2>&1
if not "%ERRORLEVEL%"=="0" if not "%enc_error%"=="1" (
   echo %MessageVMAFCompareError%
   echo %date% %time%>>%error_log%
   echo %MessageVMAFCompareError% >>%error_log%
   echo Input video>>%error_log%
   echo "%InputVideo%">>%error_log%
   echo Comparison video>>%error_log%
   echo "%movie_dir%%OutputVideo%">>%error_log%
   echo.>>%error_log%
   set Compare_error=1
   echo.
   timeout /T %wait%
)
popd

pushd "%log_dir%"
if not "%enc_error%"=="1" if not "%Compare_error%"=="1" (
   for /f "DELIMS=" %%i IN ('find "Parsed_ssim" "%OutputVideoNoExt%_ssim(%CompareBitDepth%)_log%pass_orig%.txt"') DO SET "Parsed_ssim=%%i"
   for /f "DELIMS=" %%i IN ('find "Parsed_psnr" "%OutputVideoNoExt%_ssim(%CompareBitDepth%)_log%pass_orig%.txt"') DO SET "Parsed_psnr=%%i"
)
if not "%enc_error%"=="1" if not "%Compare_error%"=="1" (
   for /f "tokens=5" %%i in ("%Parsed_ssim%") do set "SSIM_Y=%%i"
   for /f "tokens=11" %%i in ("%Parsed_ssim%") do set "SSIM_All=%%i"
   for /f "tokens=5" %%i in ("%Parsed_psnr%") do set "PSNR_Y=%%i"
   for /f "tokens=8" %%i in ("%Parsed_psnr%") do set "PSNR_Average=%%i"
   FOR /f "tokens=4" %%i IN ('find "VMAF score = " "%OutputVideoNoExt%_vmaf(%CompareBitDepth%)_log%pass_orig%.txt"') DO SET "VMAF=%%i"
   FOR /f "tokens=4" %%i IN ('find "MS-SSIM score = " "%OutputVideoNoExt%_vmaf(%CompareBitDepth%)_log%pass_orig%.txt"') DO SET "MS-SSIM=%%i"
)
if not "%enc_error%"=="1" if not "%Compare_error%"=="1" (
   set "SSIM_Y=%SSIM_Y:~2%"
   set "SSIM_All=%SSIM_All:~4%"
   set "PSNR_Y=%PSNR_Y:~2%"
   set "PSNR_Average=%PSNR_Average:~8%"
   set /a "echo_bitrare=%Filesize%/%Duration2%*8"
   for /f "DELIMS=" %%i IN ('PowerShell %Filesize%*8/%Duration2%') DO SET "bitrate=%%i"
   if not "%msec_total%"=="0" for /f "DELIMS=" %%i IN ('PowerShell "%enc_fps%"') DO SET "fps=%%i"
   if not "%msec_total%"=="0" for /f "DELIMS=" %%i IN ('PowerShell "%msec_total%/1000"') DO SET "Sec=%%i"
   for /f "DELIMS=" %%i IN ('PowerShell "(%Filesize%*8)/(%Width%*%Height%*%FrameCount%)"') DO SET "bpp=%%i"
)
if not "%enc_error%"=="1" if not "%Compare_error%"=="1" (
   if not exist "%InputVideoNoExt%_%CsvName%_(%CompareBitDepth%).csv" echo Filename,bitrate,bpp,PSNR_Y,PSNR_Average,SSIM_Y,SSIM_All,VMAF,MS-SSIM,fps,Sec,CommandLine>"%InputVideoNoExt%_%CsvName%_(%CompareBitDepth%).csv"
   echo "%OutputVideo%",%bitrate%,%bpp%,%PSNR_Y%,%PSNR_Average%,%SSIM_Y%,%SSIM_All%,%VMAF%,%MS-SSIM%,%fps%,%Sec%,"%CommandLine_orig%"|%safetee% -a "%InputVideoNoExt%_%CsvName%_(%CompareBitDepth%).csv" >nul
)

for /f "delims=" %%a in ('PowerShell "-Join (Get-Random -Count 32 -input 0,1,2,3,4,5,6,7,8,9,a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z)"') do set "random32=%%a"
copy /Y "%InputVideoNoExt%_%CsvName%_(%CompareBitDepth%).csv" "%TEMP%\temp_%random32%.txt">nul
%busybox64% awk -v ORS="\r\n" "!a[$0]++" "%TEMP%\temp_%random32%.txt" >"%InputVideoNoExt%_%CsvName%_(%CompareBitDepth%).csv"
del "%TEMP%\temp_%random32%.txt">nul 2>&1
popd

if not "%enc_error%"=="1" if not "%Compare_error%"=="1" call echo %MessageResultOutputName%
if not "%enc_error%"=="1" if not "%Compare_error%"=="1" (
   echo bitrate                     : %echo_bitrare% kbps
   echo SSIM  ^(Y^)                   : %SSIM_Y% ^(%CompareBitDepth%^)
   echo SSIM  ^(All^)                 : %SSIM_All% ^(%CompareBitDepth%^)
   echo PSNR  ^(Y^)                   : %PSNR_Y% ^(%CompareBitDepth%^)
   echo PSNR  ^(AVERAGE^)             : %PSNR_Average% ^(%CompareBitDepth%^)
   echo VMAF                        : %VMAF% ^(%CompareBitDepth%^)
   echo MS-SSIM                     : %MS-SSIM% ^(%CompareBitDepth%^)
   if not "%msec_total%"=="0" if not "%multipass%"=="1" call echo %MessageResultFPS%
   if not "%msec_total%"=="0" if "%multipass%"=="1" call echo %MessageResultFPSMultiPass%
   if not "%msec_total%"=="0" if not "%multipass%"=="1" call echo %MessageResultTime%
   if not "%msec_total%"=="0" if "%multipass%"=="1" call echo %MessageResultTimeMultiPass%
   echo.
   echo.
   echo.
)

if "%del_enc_file%"=="1" del "%movie_dir%%OutputVideo%"

:input_error_skip
rem 一通りの処理が終了
endlocal

set input_error=
goto end

rem サブルーチン
:variable_set
set "arg=%~1"
set "variable=%~2"
call set %variable%=
set loop_num=1
:variable_set2
if %loop_num% gtr 20 exit /b
if "%~3"=="%arg%" call set "%variable%=%~4"&&exit /b
shift
set /a loop_num=loop_num+1
goto variable_set2
exit /b

:pass_number_set
set multipass=1
set pass_temp=1
set pt=1
set pt2=2
:pass_number_set2
for /f "tokens=%pt%,%pt2% delims== " %%1 in ("%CommandLine%") do if "%%1"=="%1" (
   set pass_orig=%%2
   exit /b
) else (
   set /a pt=pt+1
   set /a pt2=pt2+1
   goto pass_number_set2
)
exit /b

:multi_pass_set
if "%pass_temp%"=="1" if "%multipasstype%"=="0" for /f "delims=" %%i in ('PowerShell -command "& {""""%CommandLine%"""" -replace """"-pass %pass_orig%"""",""""-pass 1""""}"') do set "CommandLine=%%i"
if "%pass_temp%"=="1" if "%multipasstype%"=="1" for /f "delims=" %%i in ('PowerShell -command "& {""""%CommandLine%"""" -replace """"--pass=%pass_orig%"""",""""--pass=1 --fpf=temp.fpf""""}"') do set "CommandLine=%%i"
if "%pass_temp%"=="%pass_orig%" (
   if not "%pass_orig%"=="1" (
      if "%multipasstype%"=="0" for /f "delims=" %%i in ('PowerShell -command "& {""""%CommandLine%"""" -replace """"-pass %pass_orig%"""",""""-pass 2""""}"') do set "CommandLine=%%i"
      if "%multipasstype%"=="1" for /f "delims=" %%i in ('PowerShell -command "& {""""%CommandLine%"""" -replace """"--pass=%pass_orig%"""",""""--pass=2 --fpf=temp.fpf""""}"') do set "CommandLine=%%i"
   )
) else (
   for /f "delims=" %%i in ('PowerShell -command "& {""""%CommandLine%"""" -replace """"-pass %pass_orig%"""",""""-pass 3""""}"') do set "CommandLine=%%i"
)
exit /b

:msec_to_sec
rem csvに書き込むデータを計算
if not "%multipass%"=="1" set enc_fps=%FrameCount%/(%enc_msec%/1000)
if "%multipass%"=="1" if "%pass_temp%"=="1" call set enc_fps=(%FrameCount%*%pass_orig%)/((%%enc_msec%pass_temp%%%/1000)
if "%multipass%"=="1" if not "%pass_temp%"=="1" if not "%pass_temp%"=="%pass_orig%" call set enc_fps=%enc_fps%+(%%enc_msec%pass_temp%%%/1000)
if "%multipass%"=="1" if "%pass_temp%"=="%pass_orig%" call set enc_fps=%enc_fps%+(%%enc_msec%pass_temp%%%/1000))
if "%multipass%"=="1" if "%pass_orig%"=="1" call set enc_fps=%FrameCount%/(%%enc_msec%pass_temp%%%/1000)

rem 表示用のデータを計算
if not defined msec_total set msec_total=0
call set /a msec_total=msec_total+%%enc_msec%pass_temp%%%

set /a echo_sec=%msec_total%/1000
set /a echo_hour=%echo_sec%/3600
set /a echo_min=(echo_sec%%3600)/60
set /a echo_sec=echo_sec%%60
if %msec_total% geq 1000 set echo_msec=%msec_total:~-3%
if %msec_total% lss 1000 set echo_msec=%msec_total%
exit /b

:error_check
if not exist "%~2" goto error_check2
if "%~z2"=="0" goto error_check2
exit /b
:error_check2
set enc_error=1
if exist "%~2" del "%~2"

echo %date% %time%>>%error_log%
(echo %MessageEncodeErrorLine1%
echo %MessageEncodeErrorLine2%
echo Input video  "%~1"
echo Output video "%~2"
echo CommandLine "%codec% %CommandLine%"
echo.) | %safetee% -a %error_log%
timeout /t %wait%
exit /b

:end
exit /b
