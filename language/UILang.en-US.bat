set "MessageArgumentErrorLine1=error:Invalid argument to call bat"
set "MessageArgumentErrorLine2=usage: video_benchmark.bat -i Input_video -o Output_filename -codec Encoder_name -cmd Encoder_commandline [options]"
set "MessageArgumentErrorLine3=Options:"
set "MessageArgumentErrorLine4=            -i             Input video"
set "MessageArgumentErrorLine5=            -o             Output filename"
set "MessageArgumentErrorLine6=            -codec         Encoder name"
set "MessageArgumentErrorLine7=            -cmd           Encoder commandline"
set "MessageArgumentErrorLine8=            -csvsuf        CSV name suffix                          *optional"
set "MessageArgumentErrorLine9=            -encode-depth  Encoding bit depth                       *optional"
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
set "MessageResultFPS=Encoded fps                 : %%fps%% fps"
set "MessageResultFPSMultiPass=Encoded fps                 : %%fps%% fps ^(%%pass_orig%%pass total^)"
set "MessageResultTime=Elapsed time                : %%echo_hour%% hour %%echo_min%% minutes %%echo_sec%%.%%echo_msec%% seconds"
set "MessageResultTimeMultiPass=Elapsed time                : %%echo_hour%% hour %%echo_min%% minutes %%echo_sec%%.%%echo_msec%% seconds ^(%%pass_orig%%pass total^)"
set "MessageEncodeErrorLine1=video encoding may have failed"
set "MessageEncodeErrorLine2=There may be a problem with the input file or the command line may be incorrect"
set "MessageFrameCountError=The FrameCount in the input file and the output file does not match"
exit /b
