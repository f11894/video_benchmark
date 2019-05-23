@echo off
rem benchmark_logフォルダをドロップして使う

cd "%~1"
echo グラフを作成しています
"%~dp0tools\Create_Graph.exe" "%~1"
echo グラフの作成が終了しました
pause
