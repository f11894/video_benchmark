@echo off
rem benchmark_logフォルダをドロップして使う
rem 予めPythonをインストールしてあることが前提

cd "%~1"
echo グラフを作成しています
Python "%~dp0Create_Graph.py" "%~nx1" 8bit
Python "%~dp0Create_Graph.py" "%~nx1" 10bit
echo グラフの作成が終了しました
pause
