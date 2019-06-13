if exist "%~dpn1_%~2.bin" exit /b
echo "VTM %~3" >>"%~dp1%~n1_benchmark_log\%~n1_%~2_log.txt"
%timer64% %VTM%  -c %VTM_cfg% %~3 -fr %~8 -wdt %~4 -hgt %~5 -f %~6 -i "%~dpn1_temp8bit.yuv" -o "%~dpn1_%~2.yuv" -b "%~dpn1_%~2.bin" >>"%~dp1%~n1_benchmark_log\%~n1_%~2_log.txt" 2>&1 
%ffmpeg% -y -f rawvideo -s %~4x%~5 -r %~7 -pix_fmt yuv420p -strict -2 -i "%~dpn1_%~2.yuv" "%~dpn1_%~2.y4m" >>"%~dp1%~n1_benchmark_log\%~n1_%~2_log.txt" 2>&1 &&del "%~dpn1_%~2.yuv"
exit /b
