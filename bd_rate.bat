@echo off
cd "%~dp0"
for %%i in (bd_codecs_all_variants.py,bd_codecs_sorted.py) do (
    if not exist .\tools\%%i curl -L "https://github.com/f11894/AV1-benchmarks/raw/master/2020.11.04%%20Aomenc%%20LIF/Make%%20Plots%%E2%%81%%84BD-Rates/%%i" -o .\tools\%%i
)
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
python .\tools\bd_codecs_all_variants.py %bddatefiles%
python .\tools\bd_codecs_sorted.py %bddatefiles%
pause
exit /b
