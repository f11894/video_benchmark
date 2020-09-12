# video_benchmark
bat files that benchmark the performance of various encoders

You can calculate PSNR, SSIM and VMAF scores and output them to csv to create a graph.  
There is also an encoding speed measurement and an automatic multipath encoding function.  

### Usage

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
                       XVC
  -cmd                 encoder command line
  -csvsuf              CSV file name suffix *optional
  -encode-depth        encoding bit-depth (8 or 10) *optional
```
The included preset bat provides more specific instructions.  
Alternatively, drag and drop the video file into the preset bat.  
After encoding, drag and drop the "benchmark_log" folder into Create_Graph.bat to create the graph.  

If you want to calculate the average value of multiple files  
1. Download and unzip the dataset, for example, objective-1-fast, from [here](https://media.xiph.org/video/derf/)  
2. Next, select all the y4m files in the objective-1-fast folder and convert them with an appropriate preset.  
3. After all conversions are done, drop the objective-1-fast folder into Average_of_multiple_csv.bat and calculate the average value of csv  
4. In the objective-1-fast folder, a folder called objective-1-fast_benchmark_log is created, so drop that folder into Create_Graph.bat to create a graph  

### important point  
When benchmarking with 10bit, rewrite ComparePixelFormat in video_benchmark.bat from yuv420p to yuv420p10le (even in the case of 8bit and 10bit mixed benchmarks)

If the fps of the video before encoding and the video after encoding are not aligned, the score such as SSIM will be measured abnormally low.  
Use a constant frame rate for the source video, not a variable frame rate.  