@echo off
rem benchmark_log�t�H���_�̏�̃t�H���_���h���b�v���Ďg��

cd "%~1"
Python "%~dp0tools\Calculate_average_value.py" "%~1"
pause
