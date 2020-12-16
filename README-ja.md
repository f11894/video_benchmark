# video_benchmark
各種エンコーダーの性能をベンチマークをするbatファイル群

PSNR、SSIM、VMAFのスコアを算出してcsvに出力したりグラフを作成することが出来ます  
エンコード速度の計測や自動マルチパスエンコード機能もあります  

### 使い方

```console
Example: video_benchmark.bat -codec x264 -i input.y4m -o output.mp4 -cmd "--crf 23"

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
                       VVenC
                       XVC
  -cmd                 encoder command line
  -csvsuf              CSV file name suffix *optional
  -encode-depth        encoding bit-depth (8 or 10) *optional
```
具体的な使い方は同梱してあるプリセット用のbatを見ればわかるかと思います  
もしくはプリセット用のbatに動画ファイルをドラッグ&ドロップしてください  
エンコードが終わったらbenchmark_logフォルダをplot.batにドラッグ&ドロップしてグラフを作成します  

複数ファイルの平均値を算出したい場合  
1. 例えば[ここ](https://media.xiph.org/video/derf/)からobjective-1-fastなどのdatasetをダウンロードして解凍します  
2. objective-1-fastフォルダ内のy4mを全て選択して任意のプリセットで変換します  
3. 全て変換し終わったらobjective-1-fastフォルダをcsv_ave.batにドロップしてcsvの平均値を算出します  
4. objective-1-fastフォルダ内にobjective-1-fast_benchmark_logというフォルダが作成されているので、そのフォルダをplot.batにドロップしてグラフを作成します  

BD-Rateを算出したい場合  
1. AnacondaをインストールしてPythonのパスを通してください  
2. コマンドプロンプトで「pip install Numpy matplotlib scipy」を実行します  
3. 複数のコーデックの比較をしたい場合はbenchmark_logフォルダをbd_rate.batにドラッグ&ドロップ、特定のエンコーダーの各presetの比較をしたい場合は.bddataファイルをbd_rate.batにドラッグ&ドロップしてください  
BD-Rateについては[こちらの記事](https://qiita.com/saka1_p/items/971c95049416f034342d)を参照してください  

### 注意点  
10bitでベンチマークする際はvideo_benchmark.batのComparePixelFormatをyuv420pからyuv420p10leに書き換えてください(8bitと10bitの混在したベンチマークの場合も)  

エンコード前の動画とエンコード後の動画のfpsが揃っていなかったりするとSSIMなどのスコアが異常に低く計測されてしまいます  
元の動画は可変フレームレートではなく固定フレームレートで保存しておいてください  
