if not exist "%~dp1%~n1_benchmark_log\" mkdir "%~dp1%~n1_benchmark_log\"
if exist "%~dpn1_%~2.mp4" exit /b
%ffmpeg% -y -loglevel quiet -i "%~1" -an -pix_fmt yuv420p -f yuv4mpegpipe - | %timer64% %rav1e% %~3 - -o "%~dpn1_%~2.ivf">"%~dp1%~n1_benchmark_log\%~n1_%~2_log.txt" 2>&1 
%mp4box% -add "%~dpn1_%~2.ivf" -new "%~dpn1_%~2.mp4" >>"%~dp1%~n1_benchmark_log\%~n1_%~2_log.txt" 2>&1 
chcp 932
