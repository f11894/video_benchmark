@echo off
set ffmpeg="%~dp0tools\ffmpeg.exe"
set mediaInfo="%~dp0tools\MediaInfo.exe"

%ffmpeg% -loglevel 48 -i "%~1" -t 00:00:00.00 -vcodec utvideo -an -f null - >"%TEMP%\ffmediaInfo.txt"  2>&1
FOR /f "DELIMS=" %%i IN ('find "'frame_rate'" "%TEMP%\ffmediaInfo.txt"') DO SET frame_rate=%%i
FOR /f "DELIMS=" %%i IN ('find "'video_size'" "%TEMP%\ffmediaInfo.txt"') DO SET video_size=%%i
FOR /f "tokens=4 DELIMS='" %%i IN ("%frame_rate%") DO SET frame_rate=%%i
FOR /f "tokens=1 DELIMS=/" %%i IN ("%frame_rate%") DO SET frame_rate_num=%%i
FOR /f "tokens=2 DELIMS=/" %%i IN ("%frame_rate%") DO SET frame_rate_denom=%%i
set frame_rate_mp4box=%frame_rate_num%
if "%frame_rate%"=="60000/1001" set frame_rate_mp4box=59.940
if "%frame_rate%"=="30000/1001" set frame_rate_mp4box=29.970
if "%frame_rate%"=="24000/1001" set frame_rate_mp4box=23.976
FOR /f "tokens=4 DELIMS='" %%i IN ("%video_size%") DO SET video_size=%%i
FOR /f "tokens=1 DELIMS=x" %%i IN ("%video_size%") DO SET Width=%%i
FOR /f "tokens=2 DELIMS=x" %%i IN ("%video_size%") DO SET Height=%%i
del "%TEMP%\ffmediaInfo.txt"
pushd "%~dp0tools\"
FOR /f "DELIMS=" %%i IN ('MediaInfo.exe --Inform^=Video^;%%Duration/String3%% "%~1"') DO SET Duration=%%i
FOR /f "DELIMS=" %%i IN ('MediaInfo.exe --Inform^=Video^;%%FrameCount%% "%~1"') DO SET FrameCount=%%i
popd
exit /b
