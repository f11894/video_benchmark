@echo off
rem benchmark_log�t�H���_���h���b�v���Ďg��
rem �\��Python���C���X�g�[�����Ă��邱�Ƃ��O��

cd "%~1"
echo �O���t���쐬���Ă��܂�
Python "%~dp0Create_Graph.py" "%~nx1" 8bit
Python "%~dp0Create_Graph.py" "%~nx1" 10bit
echo �O���t�̍쐬���I�����܂���
pause
