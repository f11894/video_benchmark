rem 出力ファイルの保存場所と名前
set "log_dir=%~dp1%~n1_benchmark_log\"
set "movie_dir=%~dp1"
set error_log="%log_dir%%~n1__error_log.txt"

rem QSVのcqpとvqpの時PフレームとBフレームの数値をIフレームよりいくつ上の数字にするか
set QP_p_n=2
set QP_b_n=5

rem エンコードして出来たファイルを削除する 1で有効
set del_enc_file=0
rem SSIMとPSNRの1フレーム毎の詳細なログを取る 1で有効
set verbose_log=0
rem エラーが起きた時に何秒待機するか
set wait=60

rem VMAFの算出を行うかどうか 1だと算出する
rem VMAFは優秀なメトリックだが算出に時間がかかる
set EnableVMAF=1

rem VMAFの算出を行う時にMS-SSIMも算出を行うかどうか 1だと算出する
set EnableMSSSIM=0

rem SSIMやVMAFを算出する時のビット深度
set ComparePixelFormat=-pix_fmt yuv420p

rem ソフトのパス
set ffmpeg="%~dp2tools\ffmpeg.exe"
if "%ffmpeg_enc%"=="" set ffmpeg_enc=%ffmpeg%
set ffmpeg_VMAF="%~dp2tools\ffmpeg_vmaf.exe"
set mediaInfo="%~dp2tools\MediaInfo.exe"
set timer64="%~dp2tools\timer64.exe"
set safetee="%~dp2tools\safetee.exe"
set busybox64="%~dp2tools\busybox64.exe"
set x264="%~dp2tools\x264_2969_x64.exe"
set x265="%~dp2tools\x265_3.1+2_x64.exe"
set QSVEncC="%~dp2tools\QSVEncC\x64\QSVEncC64.exe"
set VCEEncC="%~dp2tools\VCEEncC\x64\VCEEncC64.exe"
set NVEncC="%~dp2tools\VCEEncC\x64\NVEncC64.exe"
set vpxenc="%~dp2tools\vpxenc.exe"
set aomenc="%~dp2tools\aomenc.exe"
set rav1e="%~dp2tools\rav1e-20190616-v0.1.0-6d330d2.exe"
set SVT-AV1="%~dp2tools\SvtAv1EncApp.exe"
set SVT-VP9="%~dp2tools\SvtVp9EncApp.exe"
set SVT-HEVC="%~dp2tools\SvtHevcEncApp.exe"
set VTM="%~dp2tools\vtm\EncoderApp.exe"
set xvcenc="%~dp2tools\xvcenc.exe"
set mp4box="%~dp2tools\mp4box.exe"

exit /b
