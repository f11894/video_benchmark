rem �o�̓t�@�C���̕ۑ��ꏊ�Ɩ��O
set "log_dir=%~dp1%~n1_benchmark_log\"
set "movie_dir=%~dp1"
set error_log="%log_dir%%~n1__error_log.txt"

rem QSV��cqp��vqp�̎�P�t���[����B�t���[���̐��l��I�t���[����肢����̐����ɂ��邩
set QP_p_n=2
set QP_b_n=5

rem �G���R�[�h���ďo�����t�@�C�����폜���� 1�ŗL��
set del_enc_file=0
rem SSIM��PSNR��1�t���[�����̏ڍׂȃ��O����� 1�ŗL��
set verbose_log=0
rem �G���[���N�������ɉ��b�ҋ@���邩
set wait=60

rem VMAF�̎Z�o���s�����ǂ��� 1���ƎZ�o����
rem VMAF�͗D�G�ȃ��g���b�N�����Z�o�Ɏ��Ԃ�������
set EnableVMAF=1

rem VMAF�̎Z�o���s������MS-SSIM���Z�o���s�����ǂ��� 1���ƎZ�o����
set EnableMSSSIM=0

rem SSIM��VMAF���Z�o���鎞�̃r�b�g�[�x
set ComparePixelFormat=-pix_fmt yuv420p

rem �\�t�g�̃p�X
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
