# video_benchmark
各種エンコーダーの性能をベンチマークをするbatファイル群

PSNR、SSIM、VMAFのスコアを算出してcsvに出力したりグラフを作成することが出来ます  
エンコード速度の計測や自動マルチパスエンコード機能もあります  

### 使い方

```console
Usage: video_benchmark.bat -codec x264 -i input.y4m -o output.mp4 -cmd "--crf 23"

  -i                   input video path
  -o                   output video path
  -codec               the following encoders
                       x264
                       x265
                       QSVEncV
                       VCEEncC
                       NVEncC
                       FFmpeg
                       libvpx
                       libaom
                       rav1e
                       SVT-HEVC
                       SVT-VP9
                       SVT-AV1
                       VTM
                       XVC
  -cmd                 encoder command line
  -csvsuf              CSV file name suffix *optional
  -encode-depth        encoding bit-depth (8 or 10) *optional
```
具体的な使い方は同梱してあるプリセット用のbatを見ればわかるかと思います  
もしくはプリセット用のbatに動画ファイルをドラッグ&ドロップしてください  
エンコードが終わったらbenchmark_logフォルダをCreate_Graph.batにドラッグ&ドロップしてグラフを作成します  

### 注意点  
10bitでベンチマークする際はuser_setting.batのComparePixelFormatをyuv420pからyuv420p10leに書き換えてください(8bitと10bitの混在したベンチマークの場合も)  

エンコード前の動画とエンコード後の動画のfpsが揃っていなかったりするとSSIMなどのスコアが異常に低く計測されてしまいます  
元の動画は可変フレームレートではなく固定フレームレートで保存しておいてください  
