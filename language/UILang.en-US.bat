set "MessageArgumentErrorLine1=error.Invalid argument to call bat."
set "MessageArgumentErrorLine2=usage: video_benchmark.bat InputVideo OutputFileName EncoderCommandLine EncoderName csvFileName"
set "MessageInputVideoCheck=Checking information of input file."
set "MessageInputVideoCheckError=Input file may not be a video."
set "MessageInputVideoInfoFileName=Input file                  : "%%~nx1""
set "MessageInputVideoInfoVideoSize=Video size                  : %%video_size%%"
set "MessageInputVideoInfoFrameRate=Frame rate                  : %%frame_rate%%"
set "MessageInputVideoInfoFrameCount=Frame count                 : %%FrameCount%%"
set "MessageInputVideoInfoDuration=Duration                    : %%Duration%%"
set "MessagePleaseWait=Please wait."
set "MessageIntermediateFileEncode=Creating intermediate file for input."
set "MessageEncodeSkip=Since the file with the same name exists in the output destination, encoding processing is skipped."
set "MessageSSIMCompare=Calculating SSIM and PSNR for "%%~nx2"."
set "MessageVMAFCompare=Calculating VMAF for "%%~nx2"."
set "MessageSSIMCompareError=Calculation of SSIM and PSNR failed."
set "MessageVMAFCompareError=Calculation of VMAF failed."
set "MessageResultOutputName=Output file                 : "%%~nx2""
set "MessageResultFPS=Encoded fps                 : %%enc_fps_calc%% fps"
set "MessageResultFPSMultiPass=Encoded fps                 : %%enc_fps_calc%% fps ^(%pass_orig%pass average^)"
set "MessageResultTime=Elapsed time                : %%echo_hour%%:%%echo_min%%:%%echo_sec%%.%%echo_msec%%"
set "MessageResultTimeMultiPass=Elapsed time                : %echo_hour%:%echo_min%:%echo_sec%.%echo_msec% ^(%pass_orig%pass total^)"
set "MessageEncodeErrorLine1=video encoding may have failed."
set "MessageEncodeErrorLine2=There may be a problem with the input file or the command line may be incorrect."
exit /b
