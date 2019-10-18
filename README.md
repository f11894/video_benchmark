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
  
複数ファイルの平均値を算出したい場合  
1 例えば[ここ](https://media.xiph.org/video/derf/)からobjective-1-fastなどのdatasetをダウンロードして解凍します  
2 次にobjective-1-fastフォルダ内のy4mを全て選択して適当なプリセットで変換します  
3 全て変換し終わったらobjective-1-fastフォルダをCalculate_average_value.batにドラッグ&ドロップしてcsvの平均値を算出します  
4 objective-1-fastフォルダ内にobjective-1-fast_benchmark_logというフォルダが作成されているので、そのフォルダをCreate_Graph.batにドラッグ&ドロップしてグラフを作成します  

### 注意点  
10bitでベンチマークする際はuser_setting.batのComparePixelFormatをyuv420pからyuv420p10leに書き換えてください(8bitと10bitの混在したベンチマークの場合も)  

エンコード前の動画とエンコード後の動画のfpsが揃っていなかったりするとSSIMなどのスコアが異常に低く計測されてしまいます  
元の動画は可変フレームレートではなく固定フレームレートで保存しておいてください  
