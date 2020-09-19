@echo off
rem Drag and drop the objective-1-fast folder

cd "%~1"
"%~dp0tools\csv_ave.exe" "%~1"
pause
