set "MessageArgumentErrorLine1=エラー batを呼び出す引数が正しくありません"
set "MessageArgumentErrorLine2=usage: video_benchmark.bat -i 入力動画 -o 出力ファイル名 -cmd エンコーダーのコマンドライン -codec エンコーダー名 ^(-csvsuf CSV名サフィックス -encode-depth エンコードビット深度^)"
set "MessageInputVideoCheck=入力ファイルの情報を調べています"
set "MessageInputVideoCheckError=入力ファイルは動画ではない可能性があります"
set "MessageInputVideoInfoFileName=入力ファイル                : "%%InputVideo%%""
set "MessageInputVideoInfoVideoSize=動画サイズ                  : %%video_size%%"
set "MessageInputVideoInfoFrameRate=フレームレート              : %%frame_rate%%"
set "MessageInputVideoInfoFrameCount=総フレーム数                : %%FrameCount%%"
set "MessageInputVideoInfoDuration=動画の長さ                  : %%Duration%%"
set "MessagePleaseWait=しばらくお待ちください"
set "MessageMultiPass=マルチパス"
set "MessageIntermediateFileEncode=入力に使用する中間ファイルを作成しています"
set "MessageEncodeSkip=出力先に同名のファイルが存在するのでエンコード処理をスキップします"
set "MessageSSIMCompare="%%OutputVideo%%"のSSIMとPSNRを算出しています"
set "MessageVMAFCompare="%%OutputVideo%%"のVMAFを算出しています"
set "MessageSSIMCompareError=SSIMとPSNRの算出に失敗しました"
set "MessageVMAFCompareError=VMAFの算出に失敗しました"
set "MessageResultOutputName=出力ファイル                : "%%OutputVideo%%""
set "MessageResultFPS=エンコード FPS              : %%enc_fps_calc%% fps"
set "MessageResultFPSMultiPass=エンコード FPS              : %%enc_fps_calc%% fps ^(%%pass_orig%%パス平均^)"
set "MessageResultTime=エンコード時間              : %%echo_hour%%時間%%echo_min%%分%%echo_sec%%.%%echo_msec%%秒"
set "MessageResultTimeMultiPass=エンコード時間              : %%echo_hour%%時間%%echo_min%%分%%echo_sec%%.%%echo_msec%%秒 ^(%%pass_orig%%パス合計^)"
set "MessageEncodeErrorLine1=動画のエンコードに失敗した可能性があります"
set "MessageEncodeErrorLine2=入力ファイルに問題がないか、コマンドラインが間違っていないか確認してください"
exit /b
