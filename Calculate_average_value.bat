@echo off
rem benchmark_logフォルダの上のフォルダをドロップして使う

cd "%~1"
Python "%~dp0tools\Calculate_average_value.py" "%~1"
pause
