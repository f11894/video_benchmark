@echo off
if "%language_configured%"=="1" goto ArgumentCheck
for /f "tokens=2" %%i in ('PowerShell Get-WinSystemLocale') do set "SystemLocale=%%i"
chcp 65001 >nul 2>&1
call "%~dp0language\UILang.en-US.bat"
if exist "%~dp0language\UIlang.%SystemLocale%.bat" call "%~dp0language\UIlang.%SystemLocale%.bat"
set language_configured=1

:ArgumentCheck
rem 引数チェック
if "%~1"=="" set ArgumentError=1
if "%~2"=="" set ArgumentError=1
if "%~3"=="" set ArgumentError=1
if "%~4"=="" set ArgumentError=1
if "%~5"=="" set ArgumentError=1
if "%ArgumentError%"=="1" (
   echo %MessageArgumentErrorLine1%
   echo %MessageArgumentErrorLine2%
   timeout /t 30
   exit /b
)

rem 設定ファイルの読み込み
rem user_settingが無ければdefault_settingをコピーする
if not exist "%~dp0setting\user_setting.bat" copy /y "%~dp0setting\default_setting.bat" "%~dp0setting\user_setting.bat" >nul 2>&1

call "%~dp0setting\default_setting.bat" "%~1" "%~dpnx0"
call "%~dp0setting\user_setting.bat" "%~1" "%~dpnx0"

rem 動画の情報を調べる
:ffmediaInfo
if not exist "%log_dir%" mkdir "%log_dir%"
if not exist "%movie_dir%" mkdir "%movie_dir%"
if "%ffmediaInfo_file%"=="%~1" goto start
echo %MessageInputVideoCheck%

call "%~dp0ffmediaInfo.bat" "%~1"

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
set "ffmediaInfo_file=%~1"

:start
if "%verbose_log%"=="1" set EnableMSSSIM=1
setlocal

pushd "%movie_dir%"

:enc_process
rem エンコード前の下処理
set "CommandLine=%~3"
set "codec=%~4"
set "csv_name=%codec%_%~5"
set "CompareBitDepth=Unspecified"
echo "%ComparePixelFormat%"|find "yuv420p" >nul&&set "CompareBitDepth=8bit"
echo "%ComparePixelFormat%"|find "yuv420p10le" >nul&&set "CompareBitDepth=10bit"
set "EncodePixelFormat=-pix_fmt yuv420p"
set "EncodeBitDepth=8"
if "%~6"=="10bit" (
   set "EncodePixelFormat=-pix_fmt yuv420p10le"
   set "EncodeBitDepth=10"
)

rem qsv_enc用前処理
echo "%codec%"|findstr "QSVEncC VCEEncC" >nul&& echo "%CommandLine%"|findstr /r /c:"--cqp [0-9]">nul&&call :cqp_number_set --cqp
echo "%codec%"|findstr "QSVEncC VCEEncC" >nul&& echo "%CommandLine%"|findstr /r /c:"--vqp [0-9]">nul&&call :cqp_number_set --vqp
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
if not exist "%movie_dir%%~2" (
   rem ログフォルダに以前のログが残っていたら削除する
   if exist "%log_dir%%~n2_ssim(%CompareBitDepth%)_log%pass_orig%.txt" del "%log_dir%%~n2_ssim(%CompareBitDepth%)_log%pass_orig%.txt"
   if exist "%log_dir%%~n2_vmaf(%CompareBitDepth%)_log%pass_orig%.txt" del "%log_dir%%~n2_vmaf(%CompareBitDepth%)_log%pass_orig%.txt"

   if "%multipass%"=="1" echo %MessageMultiPass% %pass_temp%/%pass_orig%&&echo.
   if "%codec%"=="QSVEncC" %timer64% "%QSVEncC%" -i "%~1" %CommandLine% -o "%movie_dir%%~2" 2>&1 | %safetee% -o "%log_dir%%~n2_log%pass_temp%.txt"
   if "%codec%"=="VCEEncC" %timer64% "%VCEEncC%" -i "%~1" %CommandLine% -o "%movie_dir%%~2" 2>&1 | %safetee% -o "%log_dir%%~n2_log%pass_temp%.txt"
   if "%codec%"=="NVEncC" %timer64% "%NVEncC%" -i "%~1" %CommandLine% -o "%movie_dir%%~2" 2>&1 | %safetee% -o "%log_dir%%~n2_log%pass_temp%.txt"
   if "%codec%"=="FFmpeg" %timer64% %ffmpeg_enc% -y -i "%~1" -an %EncodePixelFormat% %CommandLine% "%movie_dir%%~2" 2>&1 | %safetee% -o "%log_dir%%~n2_log%pass_temp%.txt"
   if "%codec%"=="x264" %view_args64% %ffmpeg% -y -i "%~1" -an %EncodePixelFormat% -strict -2 -f yuv4mpegpipe - 2>"%log_dir%%~n2_pipelog%pass_temp%.txt" | %timer64% %x264% %CommandLine% --demuxer y4m -o "%movie_dir%%~2" - 2>&1 | %safetee% -o "%log_dir%%~n2_log%pass_temp%.txt"
   if "%codec%"=="x265" %view_args64% %ffmpeg% -y -i "%~1" -an %EncodePixelFormat% -strict -2 -f yuv4mpegpipe - 2>"%log_dir%%~n2_pipelog%pass_temp%.txt" | %timer64% %x265% %CommandLine% --input - --y4m "%movie_dir%%~n2.h265" 2>&1 | %safetee% -o "%log_dir%%~n2_log%pass_temp%.txt"
   if "%codec%"=="libaom" (
      if not exist "%movie_dir%%~n1_temp%EncodeBitDepth%bit.y4m" echo %MessageIntermediateFileEncode% &&%ffmpeg% -i "%~1" -an %EncodePixelFormat% -strict -2 "%movie_dir%%~n1_temp%EncodeBitDepth%bit.y4m" >"%log_dir%%~n2_log%pass_temp%.txt" 2>&1
      %aomenc% --help | find "AOMedia Project AV1 Encoder">>"%log_dir%%~n2_log%pass_temp%.txt" 2>&1 
      %timer64% %aomenc% %CommandLine% -o "%movie_dir%%~n2.ivf" "%movie_dir%%~n1_temp%EncodeBitDepth%bit.y4m" 2>&1 | %safetee% -a "%log_dir%%~n2_log%pass_temp%.txt"
   )
   if "%codec%"=="rav1e" %view_args64% %ffmpeg% -y -i "%~1" -an %EncodePixelFormat% -strict -2 -f yuv4mpegpipe - 2>"%log_dir%%~n2_pipelog%pass_temp%.txt" | %timer64% %rav1e% - %CommandLine% -o "%movie_dir%%~n2.ivf" 2>&1 | %safetee% -o "%log_dir%%~n2_log%pass_temp%.txt"
   if "%codec%"=="SVT-AV1" %view_args64% %ffmpeg% -y -i "%~1" -an -nostdin -f rawvideo %EncodePixelFormat% -strict -2 - 2>"%log_dir%%~n2_pipelog%pass_temp%.txt" | %timer64% %SVT-AV1% -i stdin %CommandLine% -n %FrameCount% -w %Width% -h %Height% -fps-num %frame_rate_num% -fps-denom %frame_rate_denom% -b "%movie_dir%%~n2.ivf" 2>&1 | %safetee% -o "%log_dir%%~n2_log%pass_temp%.txt"
   if "%codec%"=="SVT-HEVC" %view_args64% %ffmpeg% -y -i "%~1" -an -nostdin -f rawvideo %EncodePixelFormat% -strict -2 - 2>"%log_dir%%~n2_pipelog%pass_temp%.txt" | %timer64% %SVT-HEVC% -i stdin %CommandLine% -n %FrameCount% -w %Width% -h %Height% -fps-num %frame_rate_num% -fps-denom %frame_rate_denom% -b "%movie_dir%%~n2.h265" 2>&1 | %safetee% -o "%log_dir%%~n2_log%pass_temp%.txt"
   if "%codec%"=="SVT-VP9" %view_args64% %ffmpeg% -y -i "%~1" -an -nostdin -f rawvideo %EncodePixelFormat% -strict -2 - 2>"%log_dir%%~n2_pipelog%pass_temp%.txt" | %timer64% %SVT-VP9% -i stdin %CommandLine% -n %FrameCount% -w %Width% -h %Height% -fps-num %frame_rate_num% -fps-denom %frame_rate_denom% -b "%movie_dir%%~n2.ivf" 2>&1 | %safetee% -o "%log_dir%%~n2_log%pass_temp%.txt"
   if "%codec%"=="libvpx" (
      if not exist "%movie_dir%%~n1_temp%EncodeBitDepth%bit.y4m" echo %MessageIntermediateFileEncode% &&%ffmpeg% -i "%~1" -an %EncodePixelFormat% -strict -2 "%movie_dir%%~n1_temp%EncodeBitDepth%bit.y4m" >"%log_dir%%~n2_log%pass_temp%.txt" 2>&1
      %vpxenc% --help | find "WebM Project">>"%log_dir%%~n2_log%pass_temp%.txt" 2>&1 
      %timer64% %vpxenc% %CommandLine% -o "%movie_dir%%~2" "%movie_dir%%~n1_temp%EncodeBitDepth%bit.y4m" 2>&1 | %safetee% -a "%log_dir%%~n2_log%pass_temp%.txt"
   )
   if "%codec%"=="VTM" (
       if not exist "%movie_dir%%~n1_temp%EncodeBitDepth%bit.yuv" echo %MessageIntermediateFileEncode% &&%ffmpeg% -i "%~1" -an %EncodePixelFormat% -f rawvideo -strict -2 "%movie_dir%%~n1_temp%EncodeBitDepth%bit.yuv" >"%log_dir%%~n2_log%pass_temp%.txt" 2>&1
       %timer64% %VTMenc%  %CommandLine% -fr %frame_rate_integer% -wdt %Width% -hgt %Height% -f %FrameCount% -i "%movie_dir%%~n1_temp%EncodeBitDepth%bit.yuv" -o NUL -b "%movie_dir%%~2" 2>&1 | %safetee% -a "%log_dir%%~n2_log%pass_temp%.txt"
   )
   if "%codec%"=="xvc" (
       %view_args64% %ffmpeg% -y -i "%~1" -an %EncodePixelFormat% -strict -2 -f yuv4mpegpipe - 2>"%log_dir%%~n2_pipelog%pass_temp%.txt" | %timer64% %xvcenc% -verbose 1 -input-file - -output-file "%movie_dir%%~2" %CommandLine% 2>&1 | %safetee% -a "%log_dir%%~n2_log%pass_temp%.txt"
   )
) else (
   set enc_skip=1
   echo %MessageEncodeSkip%
)

rem エンコード後の処理
echo.
rem エラーチェック&マルチパスの途中のファイルは削除する
set ErrorCheckFile="%movie_dir%%~2"
if "%codec%"=="x265" set ErrorCheckFile="%movie_dir%%~n2.h265"
if "%codec%"=="SVT-HEVC" set ErrorCheckFile="%movie_dir%%~n2.h265"
if "%codec%"=="rav1e" set ErrorCheckFile="%movie_dir%%~n2.ivf"
if "%codec%"=="libaom" set ErrorCheckFile="%movie_dir%%~n2.ivf"
if "%codec%"=="SVT-AV1" set ErrorCheckFile="%movie_dir%%~n2.ivf"
if "%codec%"=="SVT-VP9" set ErrorCheckFile="%movie_dir%%~n2.ivf"

if not "%enc_skip%"=="1" call :error_check "%~1" %ErrorCheckFile%
if "%multipass%"=="1" if not "%enc_skip%"=="1" if not "%pass_temp%"=="%pass_orig%" if exist %ErrorCheckFile% del %ErrorCheckFile%

rem そのままではFFmpegで扱えないビットストリームをy4mにデコードする
if not "%enc_error%"=="1" if not exist "%movie_dir%%~n2.y4m" (
   if "%codec%"=="VTM" (
      %VTMdec% -d %EncodeBitDepth% -b "%movie_dir%%~2" -o "%movie_dir%%~n2.yuv" 2>&1 | %safetee% -a "%log_dir%%~n2_log%pass_temp%.txt"
      %view_args64% %ffmpeg% -y -f rawvideo -s %video_size% -r %frame_rate% %EncodePixelFormat% -i "%movie_dir%%~n2.yuv" -strict -2 "%movie_dir%%~n2.y4m" >>"%log_dir%%~n2_log%pass_temp%.txt" 2>&1 &&del "%movie_dir%%~n2.yuv"
   )
   if "%codec%"=="xvc" (
      %xvcdec% -bitstream-file "%movie_dir%%~2" -output-file "%movie_dir%%~n2.yuv" 2>&1 | %safetee% -a "%log_dir%%~n2_log%pass_temp%.txt"
      %view_args64% %ffmpeg% -y -f rawvideo -s %video_size% -r %frame_rate% %EncodePixelFormat% -i "%movie_dir%%~n2.yuv" -strict -2 "%movie_dir%%~n2.y4m" >>"%log_dir%%~n2_log%pass_temp%.txt" 2>&1 &&del "%movie_dir%%~n2.yuv"
   )
)

rem 処理時間をログファイルから拾う
if not "%enc_error%"=="1" find "TotalMilliseconds : " "%log_dir%%~n2_log%pass_temp%.txt">nul 2>&1||set timer_error=1&&SET enc_msec%pass_temp%=0
if not "%enc_error%"=="1" if not "%timer_error%"=="1" FOR /f "tokens=3" %%i IN ('find "TotalMilliseconds : " "%log_dir%%~n2_log%pass_temp%.txt"') DO SET enc_msec%pass_temp%=%%i
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
if not "%enc_skip%"=="1" if exist "%movie_dir%%~n2.h265" %view_args64% %mp4box% -fps %frame_rate_mp4box% -add "%movie_dir%%~n2.h265" -new "%movie_dir%%~2" >>"%log_dir%%~n2_log%pass_temp%.txt" 2>&1 && del "%movie_dir%%~n2.h265" & echo.
if not "%enc_skip%"=="1" if exist "%movie_dir%%~n2.ivf" (
   if "%codec%"=="SVT-VP9" (
      %view_args64% %ffmpeg% -y -r %frame_rate% -i "%movie_dir%%~n2.ivf" -c copy "%movie_dir%%~2" >>"%log_dir%%~n2_log%pass_temp%.txt" 2>&1 && del "%movie_dir%%~n2.ivf"
   ) else (
      %view_args64% %mp4box% -fps %frame_rate_mp4box% -add "%movie_dir%%~n2.ivf" -new "%movie_dir%%~2" >>"%log_dir%%~n2_log%pass_temp%.txt" 2>&1 && del "%movie_dir%%~n2.ivf"
   )
   echo.
)
chcp 65001 >nul 2>&1

rem SSIMを算出する
for %%i in ("%movie_dir%%~2") do set Filesize=%%~zi
if "%verbose_log%"=="1" set ffmpeg_ssim_option="ssim='%~n2_ssim(%CompareBitDepth%)_verbose_log.txt';[0:v][1:v]psnr='%~n2_psnr(%CompareBitDepth%)_verbose_log.txt'"
if not "%verbose_log%"=="1" set ffmpeg_ssim_option="ssim;[0:v][1:v]psnr"
popd
pushd "%log_dir%"

set CompareFile="%movie_dir%%~2"
if "%codec%"=="VTM" set CompareFile="%movie_dir%%~n2.y4m"
if "%codec%"=="xvc" set CompareFile="%movie_dir%%~n2.y4m"

find "Parsed_ssim" "%~n2_ssim(%CompareBitDepth%)_log%pass_orig%.txt">nul 2>&1 || set SSIM_check=1
if "%verbose_log%"=="1" if not exist "%log_dir%%~n2_ssim(%CompareBitDepth%)_verbose_log.txt" set SSIM_check=1
if "%verbose_log%"=="1" if not exist "%log_dir%%~n2_psnr(%CompareBitDepth%)_verbose_log.txt" set SSIM_check=1

if "%SSIM_check%"=="1" if not "%enc_error%"=="1" (
   call echo %MessageSSIMCompare%
   echo %MessagePleaseWait%
   %view_args64% %ffmpeg% -r %frame_rate% -i %CompareFile% -an %ComparePixelFormat% -strict -2 -f yuv4mpegpipe - 2>"%~n2_ssim(%CompareBitDepth%)_pipelog%pass_orig%.txt" | %view_args64% %ffmpeg% -i - -r %frame_rate% -i "%~1" -lavfi %ffmpeg_ssim_option% -an -f null - >"%~n2_ssim(%CompareBitDepth%)_log%pass_orig%.txt" 2>&1
   echo.
)
find "Parsed_ssim" "%~n2_ssim(%CompareBitDepth%)_log%pass_orig%.txt">nul 2>&1
if not "%ERRORLEVEL%"=="0" if not "%enc_error%"=="1" (
   echo %MessageSSIMCompareError%
   echo %date% %time%>>%error_log%
   echo %MessageSSIMCompareError% >>%error_log%
   echo Input File>>%error_log%
   echo "%~1">>%error_log%
   echo Comparison file>>%error_log%
   echo "%movie_dir%%~2">>%error_log%
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
if "%verbose_log%"=="1" set ffmpeg_vmaf_option="libvmaf=model_path=%vmaf_model_file%:ms_ssim=1:psnr=1:log_fmt=json:log_path='%~n2_vmaf(%CompareBitDepth%).json'"
if not "%verbose_log%"=="1" if "%EnableMSSSIM%"=="1" (
   set ffmpeg_vmaf_option="libvmaf=model_path=%vmaf_model_file%:ms_ssim=1"
) else (
   set ffmpeg_vmaf_option="libvmaf=model_path=%vmaf_model_file%"
)

find "VMAF score" "%log_dir%%~n2_vmaf(%CompareBitDepth%)_log%pass_orig%.txt">nul 2>&1 || set VMAF_check=1
if "%EnableMSSSIM%"=="1" find "MS-SSIM score" "%log_dir%%~n2_vmaf(%CompareBitDepth%)_log%pass_orig%.txt">nul 2>&1 || set VMAF_check=1
if "%verbose_log%"=="1" find "PSNR score" "%log_dir%%~n2_vmaf(%CompareBitDepth%)_log%pass_orig%.txt">nul 2>&1 || set VMAF_check=1
if "%verbose_log%"=="1" if not exist "%log_dir%%~n2_vmaf(%CompareBitDepth%).json" set VMAF_check=1

if "%VMAF_check%"=="1" if not "%enc_error%"=="1" (
   call echo %MessageVMAFCompare%
   echo %MessagePleaseWait%
   %view_args64% %ffmpeg% -r %frame_rate% -i %CompareFile% -an %ComparePixelFormat% -strict -2 -f yuv4mpegpipe - 2>"%log_dir%%~n2_vmaf(%CompareBitDepth%)_pipelog%pass_orig%.txt" | %view_args64% %ffmpeg_VMAF% -i - -r %frame_rate% -i "%~1" -filter_complex %ffmpeg_vmaf_option% -an -f null - >"%log_dir%%~n2_vmaf(%CompareBitDepth%)_log%pass_orig%.txt" 2>&1
   echo.
)
if "%verbose_log%"=="1" if exist "%~n2_vmaf(%CompareBitDepth%).json" move /Y "%~n2_vmaf(%CompareBitDepth%).json" "%log_dir%%~n2_vmaf(%CompareBitDepth%).json" >nul
find "VMAF score" "%log_dir%%~n2_vmaf(%CompareBitDepth%)_log%pass_orig%.txt">nul 2>&1
if not "%ERRORLEVEL%"=="0" if not "%enc_error%"=="1" (
   echo %MessageVMAFCompareError%
   echo %date% %time%>>%error_log%
   echo %MessageVMAFCompareError% >>%error_log%
   echo Input File>>%error_log%
   echo "%~1">>%error_log%
   echo Comparison file>>%error_log%
   echo "%movie_dir%%~2">>%error_log%
   echo.>>%error_log%
   set Compare_error=1
   echo.
   timeout /T %wait%
)
popd
:VMAF_skip

pushd "%log_dir%"
if not "%enc_error%"=="1" if not "%Compare_error%"=="1" (
   for /f "DELIMS=" %%i IN ('find "Parsed_ssim" "%~n2_ssim(%CompareBitDepth%)_log%pass_orig%.txt"') DO SET "Parsed_ssim=%%i"
   for /f "DELIMS=" %%i IN ('find "Parsed_psnr" "%~n2_ssim(%CompareBitDepth%)_log%pass_orig%.txt"') DO SET "Parsed_psnr=%%i"
)
if not "%enc_error%"=="1" if not "%Compare_error%"=="1" (
   for /f "tokens=5" %%i in ("%Parsed_ssim%") do set "SSIM_Y=%%i"
   for /f "tokens=11" %%i in ("%Parsed_ssim%") do set "SSIM_All=%%i"
   for /f "tokens=5" %%i in ("%Parsed_psnr%") do set "PSNR_Y=%%i"
   for /f "tokens=8" %%i in ("%Parsed_psnr%") do set "PSNR_Average=%%i"
   if "%EnableVMAF%"=="1" FOR /f "tokens=4" %%i IN ('find "VMAF score = " "%~n2_vmaf(%CompareBitDepth%)_log%pass_orig%.txt"') DO SET "VMAF=%%i"
   if "%EnableVMAF%"=="1" if "%EnableMSSSIM%"=="1" FOR /f "tokens=4" %%i IN ('find "MS-SSIM score = " "%~n2_vmaf(%CompareBitDepth%)_log%pass_orig%.txt"') DO SET "MS-SSIM=%%i"
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
   echo %bitrate%,%PSNR_Y%|%safetee% -a "%~n1_%csv_name%_PSNR_Y(%CompareBitDepth%).csv" >nul
   echo %bitrate%,%PSNR_Average%|%safetee% -a "%~n1_%csv_name%_PSNR_Average(%CompareBitDepth%).csv" >nul
   echo %bitrate%,%SSIM_Y%|%safetee% -a "%~n1_%csv_name%_SSIM_Y(%CompareBitDepth%).csv" >nul
   echo %bitrate%,%SSIM_All%|%safetee% -a "%~n1_%csv_name%_SSIM_All(%CompareBitDepth%).csv" >nul
   if "%EnableVMAF%"=="1" echo %bitrate%,%VMAF%|%safetee% -a "%~n1_%csv_name%_VMAF(%CompareBitDepth%).csv" >nul
   if "%EnableVMAF%"=="1" if "%EnableMSSSIM%"=="1" echo %bitrate%,%MS-SSIM%|%safetee% -a "%~n1_%csv_name%_MS-SSIM(%CompareBitDepth%).csv" >nul
   if not "%msec_total%"=="0" echo %bitrate%,%enc_fps_calc%|%safetee% -a "%~n1_%csv_name%_fps(%CompareBitDepth%).csv" >nul
   if not "%msec_total%"=="0" echo %bitrate%,%enc_sec_calc%|%safetee% -a "%~n1_%csv_name%_Time(%CompareBitDepth%).csv" >nul
   rem bpp
   echo %bpp%,%PSNR_Y%|%safetee% -a "%~n1_%csv_name%_PSNR_Y(%CompareBitDepth%)_bpp.csv" >nul
   echo %bpp%,%PSNR_Average%|%safetee% -a "%~n1_%csv_name%_PSNR_Average(%CompareBitDepth%)_bpp.csv" >nul
   echo %bpp%,%SSIM_Y%|%safetee% -a "%~n1_%csv_name%_SSIM_Y(%CompareBitDepth%)_bpp.csv" >nul
   echo %bpp%,%SSIM_All%|%safetee% -a "%~n1_%csv_name%_SSIM_All(%CompareBitDepth%)_bpp.csv" >nul
   if "%EnableVMAF%"=="1" echo %bpp%,%VMAF%|%safetee% -a "%~n1_%csv_name%_VMAF(%CompareBitDepth%)_bpp.csv" >nul
   if "%EnableVMAF%"=="1" if "%EnableMSSSIM%"=="1" echo %bpp%,%MS-SSIM%|%safetee% -a "%~n1_%csv_name%_MS-SSIM(%CompareBitDepth%)_bpp.csv" >nul
   if not "%msec_total%"=="0" echo %bpp%,%enc_fps_calc%|%safetee% -a "%~n1_%csv_name%_fps(%CompareBitDepth%)_bpp.csv" >nul
   if not "%msec_total%"=="0" echo %bpp%,%enc_sec_calc%|%safetee% -a "%~n1_%csv_name%_Time(%CompareBitDepth%)_bpp.csv" >nul
)
set random3x=%random%_%random%_%random%
for %%i in ("%~n1_%csv_name%*.csv") do (
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

if "%del_enc_file%"=="1" del "%movie_dir%%~2"

:input_error_skip
rem 一通りの処理が終了
endlocal

set input_error=
goto end

rem サブルーチン
:cqp_number_set
set qt=1
set qt2=2
:cqp_number_set2
for /f "tokens=%qt%,%qt2%" %%1 in ("%CommandLine%") do if "%%1"=="%1" (
   set QSVQP=%%2
   exit /b
) else (
   set /a qt=qt+1
   set /a qt2=qt2+1
   goto cqp_number_set2
)
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
echo Input File "%~1"
echo Output File "%~2"
echo CommandLine "%codec% %CommandLine%"
echo.
(echo %date% %time%
echo %MessageEncodeErrorLine1%
echo %MessageEncodeErrorLine2%
echo Input File  "%~1"
echo Output File "%~2"
echo CommandLine "%codec% %CommandLine%"
echo.) >>%error_log%
timeout /t %wait%
exit /b

:end
exit /b
