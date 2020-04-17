@echo off
rem Drag and drop the objective-1-fast folder

cd "%~1"
"%~dp0tools\Average_of_multiple_csv.exe" "%~1"
pause
