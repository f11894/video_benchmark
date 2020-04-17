rem How much higher is the QP of P frame and B frame higher than I frame in cqp and vqp mode of QSV
set QP_p_n=2
set QP_b_n=5

rem Delete the encoded file (1: on)
set del_enc_file=0

rem How many seconds to wait when an error occurs
set wait=60

rem Bit depth when calculating SSIM or VMAF
set ComparePixelFormat=-pix_fmt yuv420p

rem Soft path
set ffmpeg="%~dp2tools\ffmpeg.exe"
if "%ffmpeg_enc%"=="" set ffmpeg_enc=%ffmpeg%
set ffmpeg_VMAF="%~dp2tools\ffmpeg_vmaf.exe"
set mediaInfo="%~dp2tools\MediaInfo.exe"
set timer64="%~dp2tools\timer64.exe"
set view_args64="%~dp2tools\view_args64.exe"
set safetee="%~dp2tools\safetee.exe"
set busybox64="%~dp2tools\busybox64.exe"
set x264="%~dp2tools\x264.exe"
set x265="%~dp2tools\x265.exe"
set QSVEncC="%~dp2tools\QSVEncC\x64\QSVEncC64.exe"
set VCEEncC="%~dp2tools\VCEEncC\x64\VCEEncC64.exe"
set NVEncC="%~dp2tools\VCEEncC\x64\NVEncC64.exe"
set vpxenc="%~dp2tools\vpxenc.exe"
set aomenc="%~dp2tools\aomenc.exe"
set rav1e="%~dp2tools\rav1e.exe"
set SVT-AV1="%~dp2tools\SvtAv1EncApp.exe"
set SVT-VP9="%~dp2tools\SvtVp9EncApp.exe"
set SVT-HEVC="%~dp2tools\SvtHevcEncApp.exe"
set VTMenc="%~dp2tools\vtm\EncoderApp.exe"
set VTMdec="%~dp2tools\vtm\DecoderApp.exe"
set xvcenc="%~dp2tools\xvcenc.exe"
set xvcdec="%~dp2tools\xvcdec.exe"
set mp4box="%~dp2tools\mp4box.exe"

exit /b
