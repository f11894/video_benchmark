@echo off
rem datasetの入ったフォルダをドロップして使う

"%~dp0tools\Calculate_average_value.exe" -i "%~1" -d "%~nx1" -c x264_medium_tunessim_crf x265_medium_tunessim_crf
pause
