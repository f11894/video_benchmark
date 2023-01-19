@echo off
cd /d "%~dp0"
if not exist .\tools\bd_codecs_sorted.py curl -L "https://raw.githubusercontent.com/f11894/AV1-benchmarks/master/2020.12.14%%20AOM%%20VS%%20VVC%%200.2.0%%20/Make%%20Plots%%E2%%81%%84BD-Rates/bd_codecs_sorted.py" -o .\tools\bd_codecs_sorted.py
echo,
set attribute=%~a1
if %attribute:~0,1%==d goto folder
python .\tools\bd_codecs_sorted.py "%~1"
pause
exit /b

:folder
for %%i in ("%~1\*.bddata") do (
   call set bddatefiles=%%bddatefiles%%"%%i" 
)
python .\tools\bd_codecs_sorted.py %bddatefiles%
pause
exit /b
