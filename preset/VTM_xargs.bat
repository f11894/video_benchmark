if exist "%~dpn1_%~2.bin" exit /b
%timer64% %VTM%  %~3 -fr %~8 -wdt %~4 -hgt %~5 -f %~6 -i "%~dpn1_temp8bit.yuv" -b "%~dpn1_%~2.bin" >>"%~dp1%~n1_benchmark_log\%~n1_%~2_log.txt" 2>&1 
exit /b
