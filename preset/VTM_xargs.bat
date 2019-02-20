if not exist "%~dp1%~n1_benchmark_log\" mkdir "%~dp1%~n1_benchmark_log\"
if exist "%~dpn1_%~2.bin" exit /b
%timer64% %VTM%  -c %VTM_cfg% %~3 -fr %frame_rate% -wdt %Width% -hgt %Height% -f %FrameCount% -i "%~dpn1_temp8bit.yuv" -o "%~dpn1_%~2.yuv" -b "%~dpn1_%~2.bin" >"%~dp1%~n1_benchmark_log\%~n1_%~2_log.txt" 2>&1 
%ffmpeg% -y -f rawvideo -s %video_size% -r %frame_rate% -pix_fmt yuv420p -strict -2 -i "%~dpn1_%~2.yuv" "%~dpn1_%~2.y4m" >>"%~dp1%~n1_benchmark_log\%~n1_%~2_log.txt" 2>&1 &&del "%~dpn1_%~2.yuv"
