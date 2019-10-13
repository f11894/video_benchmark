set "MessageArgumentErrorLine1=error:Invalid argument to call bat"
set "MessageArgumentErrorLine2=usage: video_benchmark.bat -i InputVideo -o OutputFileName -cmd EncoderCommandLine -codec EncoderName -csv CSVFileName ^(-encode-depth EncodingBitDepth^)"
set "MessageInputVideoCheck=Checking information of input file"
set "MessageInputVideoCheckError=Input file may not be a video"
set "MessageInputVideoInfoFileName=Input file                  : "%%InputVideo%%""
set "MessageInputVideoInfoVideoSize=Video size                  : %%video_size%%"
set "MessageInputVideoInfoFrameRate=Frame rate                  : %%frame_rate%%"
set "MessageInputVideoInfoFrameCount=Frame count                 : %%FrameCount%%"
set "MessageInputVideoInfoDuration=Duration                    : %%Duration%%"
set "MessagePleaseWait=Please wait"
set "MessageMultiPass=Multi-pass"
set "MessageIntermediateFileEncode=Creating intermediate file for input"
set "MessageEncodeSkip=Since the file with the same name exists in the output destination, encoding processing is skipped"
set "MessageSSIMCompare=Calculating SSIM and PSNR for "%%OutputVideo%%""
set "MessageVMAFCompare=Calculating VMAF for "%%OutputVideo%%""
set "MessageSSIMCompareError=Calculation of SSIM and PSNR failed"
set "MessageVMAFCompareError=Calculation of VMAF failed"
set "MessageResultOutputName=Output file                 : "%%OutputVideo%%""
set "MessageResultFPS=Encoded fps                 : %%enc_fps_calc%% fps"
set "MessageResultFPSMultiPass=Encoded fps                 : %%enc_fps_calc%% fps ^(%%pass_orig%%pass average^)"
set "MessageResultTime=Elapsed time                : %%echo_hour%% hour %%echo_min%% minutes %%echo_sec%%.%%echo_msec%% seconds"
set "MessageResultTimeMultiPass=Elapsed time                : %%echo_hour%% hour %%echo_min%% minutes %%echo_sec%%.%%echo_msec%% seconds ^(%%pass_orig%%pass total^)"
set "MessageEncodeErrorLine1=video encoding may have failed"
set "MessageEncodeErrorLine2=There may be a problem with the input file or the command line may be incorrect"
exit /b
