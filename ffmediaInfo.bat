@echo off
set ffmpeg="%~dp0tools\ffmpeg.exe"
set mediaInfo="%~dp0tools\MediaInfo.exe"

pushd "%~dp0tools\"
FOR /f "DELIMS=" %%i IN ('.\ffmpeg.exe -loglevel 48 -i "%~1" -t 00:00:00.00 -vcodec utvideo -an -f null -  2^>^&1 ^| find "'frame_rate'"') DO SET "frame_rate=%%i"
FOR /f "tokens=4 DELIMS='" %%i IN ("%frame_rate%") DO SET "frame_rate=%%i"
FOR /f "tokens=1 DELIMS=/" %%i IN ("%frame_rate%") DO SET "frame_rate_num=%%i"
FOR /f "tokens=2 DELIMS=/" %%i IN ("%frame_rate%") DO SET "frame_rate_denom=%%i"
set frame_rate_mp4box=%frame_rate_num%
set frame_rate_integer=%frame_rate_num%
if "%frame_rate%"=="60000/1001" (
   set frame_rate_mp4box=59.940060
   set frame_rate_integer=60
)
if "%frame_rate%"=="30000/1001" (
   set frame_rate_mp4box=29.970030
   set frame_rate_integer=30
)
if "%frame_rate%"=="24000/1001" (
   set frame_rate_mp4box=23.976025
   set frame_rate_integer=24
)
FOR /f "DELIMS=" %%i IN ('.\MediaInfo.exe --Inform^=Video^;%%Duration/String3%% "%~1"') DO SET "Duration=%%i"
FOR /f "DELIMS=" %%i IN ('.\ffprobe -v error -count_frames -select_streams v:0 -show_entries stream^=nb_read_frames -of default^=nokey^=1:noprint_wrappers^=1 "%~1"') DO SET "FrameCount=%%i"
FOR /f "DELIMS=" %%i IN ('.\MediaInfo.exe --Inform^=Video^;%%Width%% "%~1"') DO SET "Width=%%i"
FOR /f "DELIMS=" %%i IN ('.\MediaInfo.exe --Inform^=Video^;%%Height%% "%~1"') DO SET "Height=%%i"
set "video_size=%Width%x%Height%"
popd
exit /b
