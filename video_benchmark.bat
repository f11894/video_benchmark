@echo off
rem �����`�F�b�N
if "%~1"=="" set ArgumentError=1
if "%~2"=="" set ArgumentError=1
if "%~3"=="" set ArgumentError=1
if "%~4"=="" set ArgumentError=1
if "%~5"=="" set ArgumentError=1

if "%ArgumentError%"=="1" (
   echo �G���[ bat���Ăяo������������������܂���
   echo video_benchmark.bat ���͓��� �o�̓t�@�C���� �G���R�[�_�[�̃R�}���h���C�� �G���R�[�_�[�� csv�t�@�C���� �ŌĂяo���Ă�������
   timeout /t 30
   exit /b
)

rem --------------------------------------------------------------------------------------------------------
rem �o�̓t�@�C���̕ۑ��ꏊ�Ɩ��O
set "log_dir=%~dp1%~n1_benchmark_log\"
set "movie_dir=%~dp1"

set error_log="%log_dir%%~n1__error_log.txt"

rem QSV��cqp��vqp�̎�P�t���[����B�t���[���̐��l��I�t���[����肢����̐����ɂ��邩
set QP_p_n=2
set QP_b_n=5

rem �G���R�[�h���ďo�����t�@�C�����폜���� 1�ŗL��
set del_enc_file=0
rem SSIM��PSNR��1�t���[�����̏ڍׂȃ��O����� 1�ŗL��
set verbose_log=0
rem �G���[���N�������ɉ��b�ҋ@���邩
set wait=60

rem VMAF�̎Z�o���s�����ǂ��� 1���ƎZ�o����
rem VMAF�͗D�G�ȃ��g���b�N�����Z�o�Ɏ��Ԃ�������
set EnableVMAF=1

rem SSIM��VMAF���Z�o���鎞�̃r�b�g�[�x
set ComparePixelFormat=-pix_fmt yuv420p

rem �\�t�g�̃p�X
set ffmpeg="%~dp0tools\ffmpeg.exe"
if "%ffmpeg_enc%"=="" set ffmpeg_enc=%ffmpeg%
set ffmpeg_VMAF="%~dp0tools\ffmpeg_vmaf.exe"
set mediaInfo="%~dp0tools\MediaInfo.exe"
set timer64="%~dp0tools\timer64.exe"
set safetee="%~dp0tools\safetee.exe"
set busybox64="%~dp0tools\busybox64.exe"

set x264="%~dp0tools\x264_2969_x64.exe"
set x265="%~dp0tools\x265_3.0_Au+21_x64.exe"

set QSVEncC="%~dp0tools\QSVEncC\x64\QSVEncC64.exe"
set VCEEncC="%~dp0tools\VCEEncC\x64\VCEEncC64.exe"
set NVEncC="%~dp0tools\VCEEncC\x64\NVEncC64.exe"

set vpxenc="%~dp0tools\vpxenc.exe"
set aomenc="%~dp0tools\aomenc.exe"
set rav1e="%~dp0tools\rav1e-20190427-v0.1.0-5eb7b87.exe"
set SVT-AV1="%~dp0tools\SvtAv1EncApp.exe"
set SVT-VP9="%~dp0tools\SvtVp9EncApp.exe"
set SVT-HEVC="%~dp0tools\SvtHevcEncApp.exe"

set VTM="%~dp0tools\vtm\EncoderApp.exe"

set mp4box="%~dp0tools\mp4box.exe"
rem --------------------------------------------------------------------------------------------------------

rem ����̏��𒲂ׂ�
:ffmediaInfo
if not exist "%log_dir%" mkdir "%log_dir%"
if not exist "%movie_dir%" mkdir "%movie_dir%"
if "%ffmediaInfo_file%"=="%~1" goto start
echo ���̓t�@�C���̏��𒲂ׂĂ��܂�

call "%~dp0ffmediaInfo.bat" "%~1"

if "%Duration%"=="" if "%FrameCount%"=="" (
   echo ���̓t�@�C���͓���ł͂Ȃ��\��������܂�
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
echo ����T�C�Y                  : %video_size%
echo �t���[�����[�g              : %frame_rate%
echo ���t���[����                : %FrameCount%
echo ����̒���                  : %Duration%
echo.
set "ffmediaInfo_file=%~1"

:start
setlocal

pushd "%movie_dir%"

:enc_process
rem �G���R�[�h�O�̉�����
set "CommandLine=%~3"
set "codec=%~4"
set "csv_name=%codec%_%~5"
set "CompareBitDepth=Unspecified"
echo "%ComparePixelFormat%"|find "yuv420p" >nul&&set "CompareBitDepth=8bit"
echo "%ComparePixelFormat%"|find "yuv420p10le" >nul&&set "CompareBitDepth=10bit"
set "EncodePixelFormat=-pix_fmt yuv420p"
set "EncodeBitDepth=8bit"
if "%~6"=="10bit" (
   set "EncodePixelFormat=-pix_fmt yuv420p10le"
   set "EncodeBitDepth=10bit"
)

rem qsv_enc�p�O����
echo "%codec%"|findstr "QSVEncC VCEEncC" >nul&& echo "%CommandLine%"|findstr /r /c:"--cqp [0-9]">nul&&call :cqp_number_set --cqp
echo "%codec%"|findstr "QSVEncC VCEEncC" >nul&& echo "%CommandLine%"|findstr /r /c:"--vqp [0-9]">nul&&call :cqp_number_set --vqp
set /a QP_p=%QSVQP%+%QP_p_n%
set /a QP_b=%QSVQP%+%QP_b_n%
echo "%codec%"|findstr "QSVEncC VCEEncC" >nul&& echo "%CommandLine%"|findstr /r /c:"--cqp [0-9]">nul&&call set "CommandLine=%%CommandLine:--cqp %QSVQP%=--cqp %QSVQP%:%QP_p%:%QP_b%%%"
echo "%codec%"|findstr "QSVEncC VCEEncC" >nul&& echo "%CommandLine%"|findstr /r /c:"--vqp [0-9]">nul&&call set "CommandLine=%%CommandLine:--vqp %QSVQP%=--vqp %QSVQP%:%QP_p%:%QP_b%%%"

rem �}���`�p�X�p�̏���
if not "%multipass%"=="1" echo "%CommandLine%"|findstr /r /c:"--pass [0-9]">nul&&call :pass_number_set --pass
if not "%multipass%"=="1" echo "%CommandLine%"|findstr /r /c:"-pass [0-9]">nul&&call :pass_number_set -pass
if "%multipass%"=="1" call :multi_pass_set
rem �e�G���R�[�_�[�ŃG���R�[�h
if not exist "%movie_dir%%~2" (
   rem ���O�t�H���_�ɈȑO�̃��O���c���Ă�����폜����
   if exist "%log_dir%%~n2_ssim(%CompareBitDepth%)_log%pass_orig%.txt" del "%log_dir%%~n2_ssim(%CompareBitDepth%)_log%pass_orig%.txt"
   if exist "%log_dir%%~n2_vmaf(%CompareBitDepth%)_log%pass_orig%.txt" del "%log_dir%%~n2_vmaf(%CompareBitDepth%)_log%pass_orig%.txt"
   echo %codec% %CommandLine%�ŃG���R�[�h���Ă��܂�
   echo ���΂炭���҂���������
   echo.
   if "%multipass%"=="1" echo �}���`�p�X %pass_temp%/%pass_orig%&&echo.
   echo "%codec% %CommandLine%">"%log_dir%%~n2_log%pass_temp%.txt"
   if "%codec%"=="QSVEncC" %timer64% "%QSVEncC%" -i "%~1" %CommandLine% -o "%movie_dir%%~2" 2>&1 | %safetee% -a "%log_dir%%~n2_log%pass_temp%.txt"
   if "%codec%"=="VCEEncC" %timer64% "%VCEEncC%" -i "%~1" %CommandLine% -o "%movie_dir%%~2" 2>&1 | %safetee% -a "%log_dir%%~n2_log%pass_temp%.txt"
   if "%codec%"=="NVEncC" %timer64% "%NVEncC%" -i "%~1" %CommandLine% -o "%movie_dir%%~2" 2>&1 | %safetee% -a "%log_dir%%~n2_log%pass_temp%.txt"
   if "%codec%"=="FFmpeg" %timer64% %ffmpeg_enc% -y -i "%~1" -an %EncodePixelFormat% %CommandLine% "%movie_dir%%~2" 2>&1 | %safetee% -a "%log_dir%%~n2_log%pass_temp%.txt"
   if "%codec%"=="x264" %ffmpeg% -y -i "%~1" -an %EncodePixelFormat% -strict -2 -f yuv4mpegpipe - 2>"%log_dir%%~n2_pipelog%pass_temp%.txt" | %timer64% %x264% %CommandLine% --demuxer y4m -o "%movie_dir%%~2" - 2>&1 | %safetee% -a "%log_dir%%~n2_log%pass_temp%.txt"
   if "%codec%"=="x265" %ffmpeg% -y -i "%~1" -an %EncodePixelFormat% -strict -2 -f yuv4mpegpipe - 2>"%log_dir%%~n2_pipelog%pass_temp%.txt" | %timer64% %x265% %CommandLine% --input - --y4m "%movie_dir%%~n2.h265" 2>&1 | %safetee% -a "%log_dir%%~n2_log%pass_temp%.txt"
   if "%codec%"=="libaom" (
      if not exist "%movie_dir%%~n1_temp%EncodeBitDepth%.y4m" echo ���͂Ɏg�p���钆�ԃt�@�C�����쐬���Ă��܂�&&%ffmpeg% -i "%~1" -an %EncodePixelFormat% -strict -2 "%movie_dir%%~n1_temp%EncodeBitDepth%.y4m" >>"%log_dir%%~n2_log%pass_temp%.txt" 2>&1
      %aomenc% --help | find "AOMedia Project AV1 Encoder">>"%log_dir%%~n2_log%pass_temp%.txt" 2>&1 
      %timer64% %aomenc% %CommandLine% -o "%movie_dir%%~n2.ivf" "%movie_dir%%~n1_temp%EncodeBitDepth%.y4m" 2>&1 | %safetee% -a "%log_dir%%~n2_log%pass_temp%.txt"
   )
   if "%codec%"=="rav1e" %ffmpeg% -y -i "%~1" -an %EncodePixelFormat% -strict -2 -f yuv4mpegpipe - 2>"%log_dir%%~n2_pipelog%pass_temp%.txt" | %timer64% %rav1e% - %CommandLine% -o "%movie_dir%%~n2.ivf" 2>&1 | %safetee% -a "%log_dir%%~n2_log%pass_temp%.txt"
   if "%codec%"=="SVT-AV1" %ffmpeg% -y -i "%~1" -an -nostdin -f rawvideo %EncodePixelFormat% -strict -2 - 2>"%log_dir%%~n2_pipelog%pass_temp%.txt" | %timer64% %SVT-AV1% -i stdin %CommandLine% -n %FrameCount% -w %Width% -h %Height% -fps-num %frame_rate_num% -fps-denom %frame_rate_denom% -b "%movie_dir%%~n2.ivf" 2>&1 | %safetee% -a "%log_dir%%~n2_log%pass_temp%.txt"
   if "%codec%"=="SVT-HEVC" %ffmpeg% -y -i "%~1" -an -nostdin -f rawvideo %EncodePixelFormat% -strict -2 - 2>"%log_dir%%~n2_pipelog%pass_temp%.txt" | %timer64% %SVT-HEVC% -i stdin %CommandLine% -n %FrameCount% -w %Width% -h %Height% -fps-num %frame_rate_num% -fps-denom %frame_rate_denom% -b "%movie_dir%%~n2.h265" 2>&1 | %safetee% -a "%log_dir%%~n2_log%pass_temp%.txt"
   if "%codec%"=="SVT-VP9" %ffmpeg% -y -i "%~1" -an -nostdin -f rawvideo %EncodePixelFormat% -strict -2 - 2>"%log_dir%%~n2_pipelog%pass_temp%.txt" | %timer64% %SVT-VP9% -i stdin %CommandLine% -n %FrameCount% -w %Width% -h %Height% -fps-num %frame_rate_num% -fps-denom %frame_rate_denom% -b "%movie_dir%%~n2.ivf" 2>&1 | %safetee% -a "%log_dir%%~n2_log%pass_temp%.txt"
   if "%codec%"=="libvpx" (
      if not exist "%movie_dir%%~n1_temp%EncodeBitDepth%.y4m" echo ���͂Ɏg�p���钆�ԃt�@�C�����쐬���Ă��܂�&&%ffmpeg% -i "%~1" -an %EncodePixelFormat% -strict -2 "%movie_dir%%~n1_temp%EncodeBitDepth%.y4m" >>"%log_dir%%~n2_log%pass_temp%.txt" 2>&1
      %vpxenc% --help | find "WebM Project">>"%log_dir%%~n2_log%pass_temp%.txt" 2>&1 
      %timer64% %vpxenc% %CommandLine% -o "%movie_dir%%~2" "%movie_dir%%~n1_temp%EncodeBitDepth%.y4m" 2>&1 | %safetee% -a "%log_dir%%~n2_log%pass_temp%.txt"
   )
   if "%codec%"=="VTM" (
       if not exist "%movie_dir%%~n1_temp%EncodeBitDepth%.yuv" echo ���͂Ɏg�p���钆�ԃt�@�C�����쐬���Ă��܂�&&%ffmpeg% -i "%~1" -an %EncodePixelFormat% -f rawvideo -strict -2 "%movie_dir%%~n1_temp%EncodeBitDepth%.yuv" >>"%log_dir%%~n2_log%pass_temp%.txt" 2>&1
       %timer64% %VTM%  %CommandLine% -fr %frame_rate% -wdt %Width% -hgt %Height% -f %FrameCount% -i "%movie_dir%%~n1_temp%EncodeBitDepth%.yuv" -o "%movie_dir%%~n2.yuv" -b "%movie_dir%%~2" 2>&1 | %safetee% -a "%log_dir%%~n2_log%pass_temp%.txt"
       %ffmpeg% -y -f rawvideo -s %video_size% -r %frame_rate% %EncodePixelFormat% -strict -2 -i "%movie_dir%%~n2.yuv" "%movie_dir%%~n2.y4m" >>"%log_dir%%~n2_log%pass_temp%.txt" 2>&1 &&del "%movie_dir%%~n2.yuv"
   )
) else (
   set enc_skip=1
   echo �o�͐�ɓ����̃t�@�C�������݂���̂ŃG���R�[�h�������X�L�b�v���܂�
)

rem �G���R�[�h��̏���
echo.
rem �G���[�`�F�b�N&�}���`�p�X�̓r���̃t�@�C���͍폜����
set ErrorCheckFile="%movie_dir%%~2"
if "%codec%"=="x265" set ErrorCheckFile="%movie_dir%%~n2.h265"
if "%codec%"=="SVT-HEVC" set ErrorCheckFile="%movie_dir%%~n2.h265"
if "%codec%"=="rav1e" set ErrorCheckFile="%movie_dir%%~n2.ivf"
if "%codec%"=="libaom" set ErrorCheckFile="%movie_dir%%~n2.ivf"
if "%codec%"=="SVT-AV1" set ErrorCheckFile="%movie_dir%%~n2.ivf"
if "%codec%"=="SVT-VP9" set ErrorCheckFile="%movie_dir%%~n2.ivf"

if not "%enc_skip%"=="1" call :error_check "%~1" %ErrorCheckFile%
if "%multipass%"=="1" if not "%enc_skip%"=="1" if not "%pass_temp%"=="%pass_orig%" if exist %ErrorCheckFile% del %ErrorCheckFile%

rem �������Ԃ����O�t�@�C������E��
if not "%enc_error%"=="1" findstr "^[0-9][0-9]*$" "%log_dir%%~n2_log%pass_temp%.txt">nul 2>&1||set timer_error=1&&SET enc_msec%pass_temp%=0
if not "%enc_error%"=="1" if not "%timer_error%"=="1" FOR /f "DELIMS=" %%i IN ('findstr "^[0-9][0-9]*$" "%log_dir%%~n2_log%pass_temp%.txt"') DO SET enc_msec%pass_temp%=%%i
if not "%enc_error%"=="1" call :msec_to_sec
rem �}���`�p�X�Ȃ�ŏI�p�X�ɂȂ�܂ŏ��������[�v����
if "%multipass%"=="1" if not "%pass_temp%"=="%pass_orig%" (
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
)
rem raw�t�@�C�����R���e�i�Ɋi�[
if exist "%movie_dir%%~n2.h265" %mp4box% -fps %frame_rate_mp4box% -add "%movie_dir%%~n2.h265" -new "%movie_dir%%~2" 2>&1 | %safetee% -a "%log_dir%%~n2_log%pass_temp%.txt" &&echo.&&del "%movie_dir%%~n2.h265"
if exist "%movie_dir%%~n2.ivf" (
   if "%codec%"=="SVT-VP9" (
      %ffmpeg% -y -r %frame_rate% -i "%movie_dir%%~n2.ivf" -c copy "%movie_dir%%~2" 2>&1 | %safetee% -a "%log_dir%%~n2_log%pass_temp%.txt"
   ) else (
      %mp4box% -fps %frame_rate_mp4box% -add "%movie_dir%%~n2.ivf" -new "%movie_dir%%~2" 2>&1 | %safetee% -a "%log_dir%%~n2_log%pass_temp%.txt" 
   )
   echo.
   del "%movie_dir%%~n2.ivf"
)
chcp 932 >nul 2>&1

rem SSIM���Z�o����
for %%i in ("%movie_dir%%~2") do set Filesize=%%~zi
if "%verbose_log%"=="1" set ffmpeg_ssim_option="ssim='%~n2_ssim(%CompareBitDepth%).txt';[0:v][1:v]psnr='%~n2_psnr(%CompareBitDepth%).txt'"
if not "%verbose_log%"=="1" set ffmpeg_ssim_option="ssim;[0:v][1:v]psnr"
popd
pushd "%log_dir%"

set CompareFile="%movie_dir%%~2"
if "%codec%"=="VTM" set CompareFile="%movie_dir%%~n2.y4m"

find "Parsed_ssim" "%~n2_ssim(%CompareBitDepth%)_log%pass_orig%.txt">nul 2>&1
if not "%ERRORLEVEL%"=="0" if not "%enc_error%"=="1" echo "%~nx2"��SSIM��PSNR���Z�o���Ă��܂�&&set SSIM_check=1
if "%SSIM_check%"=="1" (
   echo ���΂炭���҂���������
   %ffmpeg% -r %frame_rate% -i %CompareFile% -an %ComparePixelFormat% -strict -2 -f yuv4mpegpipe - 2>"%~n2_ssim(%CompareBitDepth%)_pipelog%pass_orig%.txt" | %ffmpeg% -i - -r %frame_rate% -i "%~1" -lavfi %ffmpeg_ssim_option% -an -f null ->>"%~n2_ssim(%CompareBitDepth%)_log%pass_orig%.txt" 2>&1
   echo.
)
find "Parsed_ssim" "%~n2_ssim(%CompareBitDepth%)_log%pass_orig%.txt">nul 2>&1
if not "%ERRORLEVEL%"=="0" if not "%enc_error%"=="1" (
   echo SSIM��PSNR�̎Z�o�Ɏ��s���܂���
   echo %date% %time%>>%error_log%
   echo SSIM��PSNR�̎Z�o�Ɏ��s���܂���>>%error_log%
   echo ���̓t�@�C��>>%error_log%
   echo "%~1">>%error_log%
   echo ��r�t�@�C��>>%error_log%
   echo "%movie_dir%%~2">>%error_log%
   echo.>>%error_log%
   set Compare_error=1
   echo.
   timeout /T %wait%
)
popd

rem VMAF�̎Z�o������skip����
if not "%EnableVMAF%"=="1" goto VMAF_skip

for %%i in (%ffmpeg_VMAF%) do set "vmaf_model_dir=%%~dpi\model"
pushd %vmaf_model_dir%
if "%verbose_log%"=="1" set ffmpeg_vmaf_option="libvmaf=model_path=vmaf_v0.6.1.pkl:ms_ssim=1:psnr=1:log_fmt=json:log_path='%~n2_vmaf(%CompareBitDepth%).json'"
if not "%verbose_log%"=="1" set ffmpeg_vmaf_option="libvmaf=model_path=vmaf_v0.6.1.pkl:ms_ssim=1"

find "VMAF score" "%log_dir%%~n2_vmaf(%CompareBitDepth%)_log%pass_orig%.txt">nul 2>&1
if not "%ERRORLEVEL%"=="0" if not "%enc_error%"=="1" echo "%~nx2"��VMAF��MS-SSIM���Z�o���Ă��܂�&&set VMAF_check=1
if "%VMAF_check%"=="1" (
   echo ���΂炭���҂���������
   %ffmpeg% -r %frame_rate% -i %CompareFile% -an %ComparePixelFormat% -strict -2 -f yuv4mpegpipe - 2>"%log_dir%%~n2_vmaf(%CompareBitDepth%)_pipelog%pass_orig%.txt" | %ffmpeg_VMAF% -i - -r %frame_rate% -i "%~1" -filter_complex %ffmpeg_vmaf_option% -an -f null - >>"%log_dir%%~n2_vmaf(%CompareBitDepth%)_log%pass_orig%.txt" 2>&1
   echo.
)
if "%verbose_log%"=="1" if exist "%~n2_vmaf(%CompareBitDepth%).json" move /Y "%~n2_vmaf(%CompareBitDepth%).json" "%log_dir%%~n2_vmaf(%CompareBitDepth%).json" >nul
find "VMAF score" "%log_dir%%~n2_vmaf(%CompareBitDepth%)_log%pass_orig%.txt">nul 2>&1
if not "%ERRORLEVEL%"=="0" if not "%enc_error%"=="1" (
   echo VMAF�̎Z�o�Ɏ��s���܂���
   echo %date% %time%>>%error_log%
   echo VMAF�̎Z�o�Ɏ��s���܂���>>%error_log%
   echo ���̓t�@�C��>>%error_log%
   echo "%~1">>%error_log%
   echo ��r�t�@�C��>>%error_log%
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
   if "%EnableVMAF%"=="1" FOR /f "tokens=4" %%i IN ('find "MS-SSIM score = " "%~n2_vmaf(%CompareBitDepth%)_log%pass_orig%.txt"') DO SET "MS-SSIM=%%i"
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
)
if not "%enc_error%"=="1" if not "%Compare_error%"=="1" (
   echo %bitrate%,%PSNR_Y%>>"%~n1_%csv_name%_PSNR_Y(%CompareBitDepth%).csv"
   echo %bitrate%,%PSNR_Average%>>"%~n1_%csv_name%_PSNR_Average(%CompareBitDepth%).csv"
   echo %bitrate%,%SSIM_Y%>>"%~n1_%csv_name%_SSIM_Y(%CompareBitDepth%).csv"
   echo %bitrate%,%SSIM_All%>>"%~n1_%csv_name%_SSIM_All(%CompareBitDepth%).csv"
   if "%EnableVMAF%"=="1" echo %bitrate%,%VMAF%>>"%~n1_%csv_name%_VMAF(%CompareBitDepth%).csv"
   if "%EnableVMAF%"=="1" echo %bitrate%,%MS-SSIM%>>"%~n1_%csv_name%_MS-SSIM(%CompareBitDepth%).csv"
   if not "%msec_total%"=="0" echo %bitrate%,%enc_fps_calc%>>"%~n1_%csv_name%_fps(%CompareBitDepth%).csv"
   if not "%msec_total%"=="0" echo %bitrate%,%enc_sec_calc%>>"%~n1_%csv_name%_Time(%CompareBitDepth%).csv"
)
for %%i in ("%~n1_%csv_name%*.csv") do (
   move /Y "%%~i" "%TEMP%\video_benchmark_temp.txt">nul
   %busybox64% awk "!a[$0]++" "%TEMP%\video_benchmark_temp.txt" | %busybox64% awk -v ORS="\r\n" "{print}" >"%%~i"
   del "%TEMP%\video_benchmark_temp.txt">nul 2>&1
)
popd

if not "%enc_error%"=="1" if not "%Compare_error%"=="1" echo �o�̓t�@�C��                : "%~nx2"
if not "%enc_error%"=="1" if not "%Compare_error%"=="1" (
   echo �r�b�g���[�g^(�ȈՓI�Ȍv�Z�l^): %echo_bitrare% kbps
   echo SSIM  ^(Y^)                   : %SSIM_Y% ^(%CompareBitDepth%^)
   echo SSIM  ^(All^)                 : %SSIM_All% ^(%CompareBitDepth%^)
   echo PSNR  ^(Y^)                   : %PSNR_Y% ^(%CompareBitDepth%^)
   echo PSNR  ^(AVERAGE^)             : %PSNR_Average% ^(%CompareBitDepth%^)
   if "%EnableVMAF%"=="1" echo VMAF                        : %VMAF% ^(%CompareBitDepth%^)
   if "%EnableVMAF%"=="1" echo MS-SSIM                     : %MS-SSIM% ^(%CompareBitDepth%^)
   if not "%msec_total%"=="0" if not "%multipass%"=="1" echo �G���R�[�h FPS              : %enc_fps_calc% fps
   if not "%msec_total%"=="0" if "%multipass%"=="1" echo �G���R�[�h FPS              : %enc_fps_calc% fps ^(%pass_orig%�p�X����^)
   if not "%msec_total%"=="0" if not "%multipass%"=="1" echo �G���R�[�h����              : %echo_hour%����%echo_min%��%echo_sec%.%echo_msec%�b
   if not "%msec_total%"=="0" if "%multipass%"=="1" echo �G���R�[�h����              : %echo_hour%����%echo_min%��%echo_sec%.%echo_msec%�b ^(%pass_orig%�p�X���v^)
   echo.
   echo.
   echo.
)

if "%del_enc_file%"=="1" del "%movie_dir%%~2"

:input_error_skip
rem ��ʂ�̏������I��
endlocal

set input_error=
goto end

rem �T�u���[�`��
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
rem csv�ɏ������ރf�[�^���v�Z
if not "%multipass%"=="1" set enc_fps=%FrameCount%/(%enc_msec%/1000)
if "%multipass%"=="1" if "%pass_temp%"=="1" call set enc_fps=(%FrameCount%*%pass_orig%)/((%%enc_msec%pass_temp%%%/1000)
if "%multipass%"=="1" if not "%pass_temp%"=="1" if not "%pass_temp%"=="%pass_orig%" call set enc_fps=%enc_fps%+(%%enc_msec%pass_temp%%%/1000)
if "%multipass%"=="1" if "%pass_temp%"=="%pass_orig%" call set enc_fps=%enc_fps%+(%%enc_msec%pass_temp%%%/1000))
if "%multipass%"=="1" if "%pass_orig%"=="1" call set enc_fps=%FrameCount%/(%%enc_msec%pass_temp%%%/1000)

rem �\���p�̃f�[�^���v�Z
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

echo ����̃G���R�[�h�Ɏ��s�����\��������܂�
echo ���̓t�@�C���ɖ�肪�Ȃ����A�R�}���h���C�����Ԉ���Ă��Ȃ����m�F���Ă�������
echo ���̓t�@�C�� "%~1"
echo �o�̓t�@�C�� "%~2"
echo �R�}���h���C�� "%codec% %CommandLine%"
echo.
(echo %date% %time%
echo ����̃G���R�[�h�Ɏ��s�����\��������܂�
echo ���̓t�@�C���ɖ�肪�Ȃ����A�R�}���h���C�����Ԉ���Ă��Ȃ����m�F���Ă�������
echo ���̓t�@�C�� "%~1"
echo �o�̓t�@�C�� "%~2"
echo �R�}���h���C�� "%codec% %CommandLine%"
echo.) >>%error_log%
timeout /t %wait%
exit /b

:end
exit /b
