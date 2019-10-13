@echo off
if "%language_configured%"=="1" goto ArgumentCheck
for /f "tokens=2" %%i in ('PowerShell Get-WinSystemLocale') do set "SystemLocale=%%i"
chcp 65001 >nul 2>&1
call "%~dp0language\UILang.en-US.bat"
if exist "%~dp0language\UIlang.%SystemLocale%.bat" call "%~dp0language\UIlang.%SystemLocale%.bat"
set language_configured=1

:ArgumentCheck
rem 引数チェック
set "EncodeBitDepth=8"
call :variable_set -cmd CommandLine %*
call :variable_set -i InputVideo %*
call :variable_set -o OutputVideo %*
call :variable_set -csvsuf CsvNameSuffix %*
call :variable_set -codec codec %*
echo "%*"|find "-encode-depth" >nul&& call :variable_set -encode-depth EncodeBitDepth %*
if defined CsvNameSuffix set "CsvNameSuffix=_%CsvNameSuffix%"
for %%i in ("%OutputVideo%") do set "OutputVideoNoExt=%%~ni"
for %%i in ("%InputVideo%") do set "InputVideoNoExt=%%~ni"
if "%codec%"=="" set ArgumentError=1
if "%InputVideo%"=="" set ArgumentError=1
if "%OutputVideo%"=="" set ArgumentError=1
if "%CommandLine%"=="" set ArgumentError=1
if "%ArgumentError%"=="1" (
   echo %MessageArgumentErrorLine1%
   echo %MessageArgumentErrorLine2%
   timeout /t 30
   exit /b
)

rem 設定ファイルの読み込み
rem user_settingが無ければdefault_settingをコピーする
if not exist "%~dp0setting\user_setting.bat" copy /y "%~dp0setting\default_setting.bat" "%~dp0setting\user_setting.bat" >nul 2>&1

call "%~dp0setting\default_setting.bat" "%InputVideo%" "%~dpnx0"
call "%~dp0setting\user_setting.bat" "%InputVideo%" "%~dpnx0"

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
if "%verbose_log%"=="1" set EnableMSSSIM=1
setlocal

pushd "%movie_dir%"

:enc_process
rem エンコード前の下処理
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
if not "%multipass%"=="1" echo "%CommandLine%"|findstr /r /c:"--pass [0-9]">nul&&call :pass_number_set --pass
if not "%multipass%"=="1" echo "%CommandLine%"|findstr /r /c:"-pass [0-9]">nul&&call :pass_number_set -pass
if not "%codec%"=="rav1e" if "%multipass%"=="1" call :multi_pass_set
rem 各エンコーダーでエンコード
if not exist "%movie_dir%%OutputVideo%" (
   rem ログフォルダに以前のログが残っていたら削除する
   if exist "%log_dir%%OutputVideoNoExt%_ssim(%CompareBitDepth%)_log%pass_orig%.txt" del "%log_dir%%OutputVideoNoExt%_ssim(%CompareBitDepth%)_log%pass_orig%.txt"
   if exist "%log_dir%%OutputVideoNoExt%_vmaf(%CompareBitDepth%)_log%pass_orig%.txt" del "%log_dir%%OutputVideoNoExt%_vmaf(%CompareBitDepth%)_log%pass_orig%.txt"

   if "%multipass%"=="1" echo %MessageMultiPass% %pass_temp%/%pass_orig%&&echo.
   if "%codec%"=="QSVEncC" %timer64% "%QSVEncC%" -i "%InputVideo%" %CommandLine% -o "%movie_dir%%OutputVideo%" 2>&1 | %safetee% -o "%log_dir%%OutputVideoNoExt%_log%pass_temp%.txt"
   if "%codec%"=="VCEEncC" %timer64% "%VCEEncC%" -i "%InputVideo%" %CommandLine% -o "%movie_dir%%OutputVideo%" 2>&1 | %safetee% -o "%log_dir%%OutputVideoNoExt%_log%pass_temp%.txt"
   if "%codec%"=="NVEncC" %timer64% "%NVEncC%" -i "%InputVideo%" %CommandLine% -o "%movie_dir%%OutputVideo%" 2>&1 | %safetee% -o "%log_dir%%OutputVideoNoExt%_log%pass_temp%.txt"
   if "%codec%"=="FFmpeg" %timer64% %ffmpeg_enc% -y -i "%InputVideo%" -an %EncodePixelFormat% %CommandLine% "%movie_dir%%OutputVideo%" 2>&1 | %safetee% -o "%log_dir%%OutputVideoNoExt%_log%pass_temp%.txt"
   if "%codec%"=="x264" %view_args64% %ffmpeg% -y -i "%InputVideo%" -an %EncodePixelFormat% -strict -2 -f yuv4mpegpipe - 2>"%log_dir%%OutputVideoNoExt%_pipelog%pass_temp%.txt" | %timer64% %x264% %CommandLine% --demuxer y4m -o "%movie_dir%%OutputVideo%" - 2>&1 | %safetee% -o "%log_dir%%OutputVideoNoExt%_log%pass_temp%.txt"
   if "%codec%"=="x265" %view_args64% %ffmpeg% -y -i "%InputVideo%" -an %EncodePixelFormat% -strict -2 -f yuv4mpegpipe - 2>"%log_dir%%OutputVideoNoExt%_pipelog%pass_temp%.txt" | %timer64% %x265% %CommandLine% --input - --y4m "%movie_dir%%OutputVideoNoExt%.h265" 2>&1 | %safetee% -o "%log_dir%%OutputVideoNoExt%_log%pass_temp%.txt"
   if "%codec%"=="libaom" (
      if not exist "%movie_dir%%InputVideoNoExt%_temp%EncodeBitDepth%bit.y4m" echo %MessageIntermediateFileEncode% && %view_args64% %ffmpeg% -i "%InputVideo%" -an %EncodePixelFormat% -strict -2 "%movie_dir%%InputVideoNoExt%_temp%EncodeBitDepth%bit.y4m" >"%log_dir%%OutputVideoNoExt%_log%pass_temp%.txt" 2>&1
      %aomenc% --help | find "AOMedia Project AV1 Encoder">>"%log_dir%%OutputVideoNoExt%_log%pass_temp%.txt" 2>&1 
      %timer64% %aomenc% %CommandLine% -o "%movie_dir%%OutputVideoNoExt%.ivf" "%movie_dir%%InputVideoNoExt%_temp%EncodeBitDepth%bit.y4m" 2>&1 | %safetee% -a "%log_dir%%OutputVideoNoExt%_log%pass_temp%.txt"
   )
   if "%codec%"=="rav1e" %view_args64% %ffmpeg% -y -i "%InputVideo%" -an %EncodePixelFormat% -strict -2 -f yuv4mpegpipe - 2>"%log_dir%%OutputVideoNoExt%_pipelog%pass_temp%.txt" | %timer64% %rav1e% - %CommandLine% -o "%movie_dir%%OutputVideoNoExt%.ivf" 2>&1 | %safetee% -o "%log_dir%%OutputVideoNoExt%_log%pass_temp%.txt"
   if "%codec%"=="SVT-AV1" %view_args64% %ffmpeg% -y -i "%InputVideo%" -an -nostdin -f rawvideo %EncodePixelFormat% -strict -2 - 2>"%log_dir%%OutputVideoNoExt%_pipelog%pass_temp%.txt" | %timer64% %SVT-AV1% -i stdin %CommandLine% -n %FrameCount% -w %Width% -h %Height% -fps-num %frame_rate_num% -fps-denom %frame_rate_denom% -b "%movie_dir%%OutputVideoNoExt%.ivf" 2>&1 | %safetee% -o "%log_dir%%OutputVideoNoExt%_log%pass_temp%.txt"
   if "%codec%"=="SVT-HEVC" %view_args64% %ffmpeg% -y -i "%InputVideo%" -an -nostdin -f rawvideo %EncodePixelFormat% -strict -2 - 2>"%log_dir%%OutputVideoNoExt%_pipelog%pass_temp%.txt" | %timer64% %SVT-HEVC% -i stdin %CommandLine% -n %FrameCount% -w %Width% -h %Height% -fps-num %frame_rate_num% -fps-denom %frame_rate_denom% -b "%movie_dir%%OutputVideoNoExt%.h265" 2>&1 | %safetee% -o "%log_dir%%OutputVideoNoExt%_log%pass_temp%.txt"
   if "%codec%"=="SVT-VP9" %view_args64% %ffmpeg% -y -i "%InputVideo%" -an -nostdin -f rawvideo %EncodePixelFormat% -strict -2 - 2>"%log_dir%%OutputVideoNoExt%_pipelog%pass_temp%.txt" | %timer64% %SVT-VP9% -i stdin %CommandLine% -n %FrameCount% -w %Width% -h %Height% -fps-num %frame_rate_num% -fps-denom %frame_rate_denom% -b "%movie_dir%%OutputVideoNoExt%.ivf" 2>&1 | %safetee% -o "%log_dir%%OutputVideoNoExt%_log%pass_temp%.txt"
   if "%codec%"=="libvpx" (
      if not exist "%movie_dir%%InputVideoNoExt%_temp%EncodeBitDepth%bit.y4m" echo %MessageIntermediateFileEncode% && %view_args64% %ffmpeg% -i "%InputVideo%" -an %EncodePixelFormat% -strict -2 "%movie_dir%%InputVideoNoExt%_temp%EncodeBitDepth%bit.y4m" >"%log_dir%%OutputVideoNoExt%_log%pass_temp%.txt" 2>&1
      %vpxenc% --help | find "WebM Project">>"%log_dir%%OutputVideoNoExt%_log%pass_temp%.txt" 2>&1 
      %timer64% %vpxenc% %CommandLine% -o "%movie_dir%%OutputVideo%" "%movie_dir%%InputVideoNoExt%_temp%EncodeBitDepth%bit.y4m" 2>&1 | %safetee% -a "%log_dir%%OutputVideoNoExt%_log%pass_temp%.txt"
   )
   if "%codec%"=="VTM" (
       if not exist "%movie_dir%%InputVideoNoExt%_temp%EncodeBitDepth%bit.yuv" echo %MessageIntermediateFileEncode% && %view_args64% %ffmpeg% -i "%InputVideo%" -an %EncodePixelFormat% -f rawvideo -strict -2 "%movie_dir%%InputVideoNoExt%_temp%EncodeBitDepth%bit.yuv" >"%log_dir%%OutputVideoNoExt%_log%pass_temp%.txt" 2>&1
       %timer64% %VTMenc%  %CommandLine% -fr %frame_rate_integer% -wdt %Width% -hgt %Height% -f %FrameCount% -i "%movie_dir%%InputVideoNoExt%_temp%EncodeBitDepth%bit.yuv" -o NUL -b "%movie_dir%%OutputVideo%" 2>&1 | %safetee% -a "%log_dir%%OutputVideoNoExt%_log%pass_temp%.txt"
   )
   if "%codec%"=="xvc" (
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
if "%codec%"=="x265" set ErrorCheckFile="%movie_dir%%OutputVideoNoExt%.h265"
if "%codec%"=="SVT-HEVC" set ErrorCheckFile="%movie_dir%%OutputVideoNoExt%.h265"
if "%codec%"=="rav1e" set ErrorCheckFile="%movie_dir%%OutputVideoNoExt%.ivf"
if "%codec%"=="libaom" set ErrorCheckFile="%movie_dir%%OutputVideoNoExt%.ivf"
if "%codec%"=="SVT-AV1" set ErrorCheckFile="%movie_dir%%OutputVideoNoExt%.ivf"
if "%codec%"=="SVT-VP9" set ErrorCheckFile="%movie_dir%%OutputVideoNoExt%.ivf"

if not "%enc_skip%"=="1" call :error_check "%InputVideo%" %ErrorCheckFile%
if "%multipass%"=="1" if not "%enc_skip%"=="1" if not "%pass_temp%"=="%pass_orig%" if exist %ErrorCheckFile% del %ErrorCheckFile%

rem そのままではFFmpegで扱えないビットストリームを可逆圧縮のH.264にデコードする
if not "%enc_error%"=="1" if not exist "%movie_dir%%OutputVideoNoExt%.mp4" (
   if "%codec%"=="VTM" (
      %VTMdec% -d %EncodeBitDepth% -b "%movie_dir%%OutputVideo%" -o "%movie_dir%%OutputVideoNoExt%.yuv" 2>&1 | %safetee% -a "%log_dir%%OutputVideoNoExt%_log%pass_temp%.txt"
      %view_args64% %ffmpeg% -y -f rawvideo -s %video_size% -r %frame_rate% %EncodePixelFormat% -i "%movie_dir%%OutputVideoNoExt%.yuv" -vcodec libx264 -qp 0 "%movie_dir%%OutputVideoNoExt%.mp4" >>"%log_dir%%OutputVideoNoExt%_log%pass_temp%.txt" 2>&1 &&del "%movie_dir%%OutputVideoNoExt%.yuv"
   )
   if "%codec%"=="xvc" (
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
   if "%codec%"=="rav1e" set "CommandLine=%CommandLine:--first-pass=--second-pass%"
   set /a pass_temp=pass_temp+1
   goto enc_process
)
if "%multipass%"=="1" (
   set "CommandLine=%~3"
   if exist ffmpeg2pass-0.log del ffmpeg2pass-0.log
   if exist ffmpeg2pass-0.log.mbtree del ffmpeg2pass-0.log.mbtree
   if exist x264_2pass.log del x264_2pass.log
   if exist x264_2pass.log.mbtree del x264_2pass.log.mbtree
   if exist x265_2pass.log del x265_2pass.log
   if exist x265_2pass.log.cutree del x265_2pass.log.cutree
   if exist rav1e_stats.json del rav1e_stats.json
   if exist rav1e_stats.log del rav1e_stats.log
)
rem rawファイルをコンテナに格納
if not "%enc_skip%"=="1" if exist "%movie_dir%%OutputVideoNoExt%.h265" %view_args64% %mp4box% -fps %frame_rate_mp4box% -add "%movie_dir%%OutputVideoNoExt%.h265" -new "%movie_dir%%OutputVideo%" >>"%log_dir%%OutputVideoNoExt%_log%pass_temp%.txt" 2>&1 && del "%movie_dir%%OutputVideoNoExt%.h265" & echo.
if not "%enc_skip%"=="1" if exist "%movie_dir%%OutputVideoNoExt%.ivf" (
   if "%codec%"=="SVT-VP9" (
      %view_args64% %ffmpeg% -y -r %frame_rate% -i "%movie_dir%%OutputVideoNoExt%.ivf" -c copy "%movie_dir%%OutputVideo%" >>"%log_dir%%OutputVideoNoExt%_log%pass_temp%.txt" 2>&1 && del "%movie_dir%%OutputVideoNoExt%.ivf"
   ) else (
      %view_args64% %mp4box% -fps %frame_rate_mp4box% -add "%movie_dir%%OutputVideoNoExt%.ivf" -new "%movie_dir%%OutputVideo%" >>"%log_dir%%OutputVideoNoExt%_log%pass_temp%.txt" 2>&1 && del "%movie_dir%%OutputVideoNoExt%.ivf"
   )
   echo.
)
chcp 65001 >nul 2>&1

rem SSIMを算出する
for %%i in ("%movie_dir%%OutputVideo%") do set Filesize=%%~zi
if "%verbose_log%"=="1" set ffmpeg_ssim_option="ssim='%OutputVideoNoExt%_ssim(%CompareBitDepth%)_verbose_log.txt';[0:v][1:v]psnr='%OutputVideoNoExt%_psnr(%CompareBitDepth%)_verbose_log.txt'"
if not "%verbose_log%"=="1" set ffmpeg_ssim_option="ssim;[0:v][1:v]psnr"
popd
pushd "%log_dir%"

set CompareVideo="%movie_dir%%OutputVideo%"
if "%codec%"=="VTM" set CompareVideo="%movie_dir%%OutputVideoNoExt%.mp4"
if "%codec%"=="xvc" set CompareVideo="%movie_dir%%OutputVideoNoExt%.mp4"

find "Parsed_ssim" "%OutputVideoNoExt%_ssim(%CompareBitDepth%)_log%pass_orig%.txt">nul 2>&1 || set SSIM_check=1
if "%verbose_log%"=="1" if not exist "%log_dir%%OutputVideoNoExt%_ssim(%CompareBitDepth%)_verbose_log.txt" set SSIM_check=1
if "%verbose_log%"=="1" if not exist "%log_dir%%OutputVideoNoExt%_psnr(%CompareBitDepth%)_verbose_log.txt" set SSIM_check=1

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

rem VMAFの算出処理をskipする
if not "%EnableVMAF%"=="1" goto VMAF_skip

set "vmaf_model_file=vmaf_v0.6.1.pkl"
if %Height% GTR 2000 set "vmaf_model_file=vmaf_4k_v0.6.1.pkl"
for %%i in (%ffmpeg_VMAF%) do set "vmaf_model_dir=%%~dpi\model"
pushd %vmaf_model_dir%
if "%verbose_log%"=="1" set ffmpeg_vmaf_option="libvmaf=model_path=%vmaf_model_file%:ms_ssim=1:psnr=1:log_fmt=json:log_path='%OutputVideoNoExt%_vmaf(%CompareBitDepth%).json'"
if not "%verbose_log%"=="1" if "%EnableMSSSIM%"=="1" (
   set ffmpeg_vmaf_option="libvmaf=model_path=%vmaf_model_file%:ms_ssim=1"
) else (
   set ffmpeg_vmaf_option="libvmaf=model_path=%vmaf_model_file%"
)

find "VMAF score" "%log_dir%%OutputVideoNoExt%_vmaf(%CompareBitDepth%)_log%pass_orig%.txt">nul 2>&1 || set VMAF_check=1
if "%EnableMSSSIM%"=="1" find "MS-SSIM score" "%log_dir%%OutputVideoNoExt%_vmaf(%CompareBitDepth%)_log%pass_orig%.txt">nul 2>&1 || set VMAF_check=1
if "%verbose_log%"=="1" find "PSNR score" "%log_dir%%OutputVideoNoExt%_vmaf(%CompareBitDepth%)_log%pass_orig%.txt">nul 2>&1 || set VMAF_check=1
if "%verbose_log%"=="1" if not exist "%log_dir%%OutputVideoNoExt%_vmaf(%CompareBitDepth%).json" set VMAF_check=1

if "%VMAF_check%"=="1" if not "%enc_error%"=="1" (
   call echo %MessageVMAFCompare%
   echo %MessagePleaseWait%
   %view_args64% %ffmpeg% -r %frame_rate% -i %CompareVideo% -an %ComparePixelFormat% -strict -2 -f yuv4mpegpipe - 2>"%log_dir%%OutputVideoNoExt%_vmaf(%CompareBitDepth%)_pipelog%pass_orig%.txt" | %view_args64% %ffmpeg_VMAF% -i - -r %frame_rate% -i "%InputVideo%" -filter_complex %ffmpeg_vmaf_option% -an -f null - >"%log_dir%%OutputVideoNoExt%_vmaf(%CompareBitDepth%)_log%pass_orig%.txt" 2>&1
   echo.
)
if "%verbose_log%"=="1" if exist "%OutputVideoNoExt%_vmaf(%CompareBitDepth%).json" move /Y "%OutputVideoNoExt%_vmaf(%CompareBitDepth%).json" "%log_dir%%OutputVideoNoExt%_vmaf(%CompareBitDepth%).json" >nul
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
:VMAF_skip

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
   if "%EnableVMAF%"=="1" FOR /f "tokens=4" %%i IN ('find "VMAF score = " "%OutputVideoNoExt%_vmaf(%CompareBitDepth%)_log%pass_orig%.txt"') DO SET "VMAF=%%i"
   if "%EnableVMAF%"=="1" if "%EnableMSSSIM%"=="1" FOR /f "tokens=4" %%i IN ('find "MS-SSIM score = " "%OutputVideoNoExt%_vmaf(%CompareBitDepth%)_log%pass_orig%.txt"') DO SET "MS-SSIM=%%i"
)
if not "%enc_error%"=="1" if not "%Compare_error%"=="1" (
   set "SSIM_Y=%SSIM_Y:~2%"
   set "SSIM_All=%SSIM_All:~4%"
   set "PSNR_Y=%PSNR_Y:~2%"
   set "PSNR_Average=%PSNR_Average:~8%"
   set /a "echo_bitrare=%Filesize%/%Duration2%*8"
   for /f "DELIMS=" %%i IN ('PowerShell %Filesize%*8/%Duration2%') DO SET "bitrate=%%i"
   if not "%msec_total%"=="0" for /f "DELIMS=" %%i IN ('PowerShell "%enc_fps%"') DO SET "enc_fps_calc=%%i"
   if not "%msec_total%"=="0" for /f "DELIMS=" %%i IN ('PowerShell "%msec_total%/1000"') DO SET "enc_sec_calc=%%i"
   for /f "DELIMS=" %%i IN ('PowerShell "(%Filesize%*8)/(%Width%*%Height%*%FrameCount%)"') DO SET "bpp=%%i"
)
if not "%enc_error%"=="1" if not "%Compare_error%"=="1" (
   echo %bitrate%,%PSNR_Y%|%safetee% -a "%InputVideoNoExt%_%CsvName%_PSNR_Y(%CompareBitDepth%).csv" >nul
   echo %bitrate%,%PSNR_Average%|%safetee% -a "%InputVideoNoExt%_%CsvName%_PSNR_Average(%CompareBitDepth%).csv" >nul
   echo %bitrate%,%SSIM_Y%|%safetee% -a "%InputVideoNoExt%_%CsvName%_SSIM_Y(%CompareBitDepth%).csv" >nul
   echo %bitrate%,%SSIM_All%|%safetee% -a "%InputVideoNoExt%_%CsvName%_SSIM_All(%CompareBitDepth%).csv" >nul
   if "%EnableVMAF%"=="1" echo %bitrate%,%VMAF%|%safetee% -a "%InputVideoNoExt%_%CsvName%_VMAF(%CompareBitDepth%).csv" >nul
   if "%EnableVMAF%"=="1" if "%EnableMSSSIM%"=="1" echo %bitrate%,%MS-SSIM%|%safetee% -a "%InputVideoNoExt%_%CsvName%_MS-SSIM(%CompareBitDepth%).csv" >nul
   if not "%msec_total%"=="0" echo %bitrate%,%enc_fps_calc%|%safetee% -a "%InputVideoNoExt%_%CsvName%_fps(%CompareBitDepth%).csv" >nul
   if not "%msec_total%"=="0" echo %bitrate%,%enc_sec_calc%|%safetee% -a "%InputVideoNoExt%_%CsvName%_Time(%CompareBitDepth%).csv" >nul
   rem bpp
   echo %bpp%,%PSNR_Y%|%safetee% -a "%InputVideoNoExt%_%CsvName%_PSNR_Y(%CompareBitDepth%)_bpp.csv" >nul
   echo %bpp%,%PSNR_Average%|%safetee% -a "%InputVideoNoExt%_%CsvName%_PSNR_Average(%CompareBitDepth%)_bpp.csv" >nul
   echo %bpp%,%SSIM_Y%|%safetee% -a "%InputVideoNoExt%_%CsvName%_SSIM_Y(%CompareBitDepth%)_bpp.csv" >nul
   echo %bpp%,%SSIM_All%|%safetee% -a "%InputVideoNoExt%_%CsvName%_SSIM_All(%CompareBitDepth%)_bpp.csv" >nul
   if "%EnableVMAF%"=="1" echo %bpp%,%VMAF%|%safetee% -a "%InputVideoNoExt%_%CsvName%_VMAF(%CompareBitDepth%)_bpp.csv" >nul
   if "%EnableVMAF%"=="1" if "%EnableMSSSIM%"=="1" echo %bpp%,%MS-SSIM%|%safetee% -a "%InputVideoNoExt%_%CsvName%_MS-SSIM(%CompareBitDepth%)_bpp.csv" >nul
   if not "%msec_total%"=="0" echo %bpp%,%enc_fps_calc%|%safetee% -a "%InputVideoNoExt%_%CsvName%_fps(%CompareBitDepth%)_bpp.csv" >nul
   if not "%msec_total%"=="0" echo %bpp%,%enc_sec_calc%|%safetee% -a "%InputVideoNoExt%_%CsvName%_Time(%CompareBitDepth%)_bpp.csv" >nul
)
set random3x=%random%_%random%_%random%
for %%i in ("%InputVideoNoExt%_%CsvName%*.csv") do (
   copy /Y "%%~i" "%TEMP%\temp_%random3x%.txt">nul
   %busybox64% awk "!a[$0]++" "%TEMP%\temp_%random3x%.txt" | %busybox64% awk -v ORS="\r\n" "{print}" >"%%~i"
   del "%TEMP%\temp_%random3x%.txt">nul 2>&1
)
popd

if not "%enc_error%"=="1" if not "%Compare_error%"=="1" call echo %MessageResultOutputName%
if not "%enc_error%"=="1" if not "%Compare_error%"=="1" (
   echo bitrate                     : %echo_bitrare% kbps
   echo SSIM  ^(Y^)                   : %SSIM_Y% ^(%CompareBitDepth%^)
   echo SSIM  ^(All^)                 : %SSIM_All% ^(%CompareBitDepth%^)
   echo PSNR  ^(Y^)                   : %PSNR_Y% ^(%CompareBitDepth%^)
   echo PSNR  ^(AVERAGE^)             : %PSNR_Average% ^(%CompareBitDepth%^)
   if "%EnableVMAF%"=="1" echo VMAF                        : %VMAF% ^(%CompareBitDepth%^)
   if "%EnableVMAF%"=="1" if "%EnableMSSSIM%"=="1" echo MS-SSIM                     : %MS-SSIM% ^(%CompareBitDepth%^)
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
for /f "tokens=%pt%,%pt2%" %%1 in ("%CommandLine%") do if "%%1"=="%1" (
   set pass_orig=%%2
   exit /b
) else (
   set /a pt=pt+1
   set /a pt2=pt2+1
   goto pass_number_set2
)
exit /b

:multi_pass_set
if "%pass_temp%"=="1" call set "CommandLine=%%CommandLine:-pass %pass_orig%=-pass 1%%"
if "%pass_temp%"=="%pass_orig%" (
   if not "%pass_orig%"=="1" call set "CommandLine=%%CommandLine:-pass %pass_orig%=-pass 2%%"
) else (
   call set "CommandLine=%%CommandLine:-pass %pass_orig%=-pass 3%%"
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

echo %MessageEncodeErrorLine1%
echo %MessageEncodeErrorLine2%
echo Input video "%~1"
echo Output video "%~2"
echo CommandLine "%codec% %CommandLine%"
echo.
(echo %date% %time%
echo %MessageEncodeErrorLine1%
echo %MessageEncodeErrorLine2%
echo Input video  "%~1"
echo Output video "%~2"
echo CommandLine "%codec% %CommandLine%"
echo.) >>%error_log%
timeout /t %wait%
exit /b

:end
exit /b
