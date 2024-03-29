# video_benchmark
bat files that benchmark the performance of various encoders

You can calculate PSNR, SSIM and VMAF scores and output them to csv to make a plot.  
There is also an encoding speed measurement and an automatic multipath encoding function.  

If you want something newer than the included encoder binary, you can download it from this link.  
https://drive.google.com/drive/folders/1fEwt2W2r5lh7zvv7ttog2u3Jt8M-ezfh

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
                       VVenC
                       XVC
  -cmd                 encoder command line
  -csvsuf              CSV file name suffix *optional
  -encode-depth        encoding bit-depth (8 or 10) *optional
```
The included preset bat provides more specific instructions.  
Alternatively, drag and drop the video file into the preset bat.  
After encoding, drag and drop the "benchmark_log" folder into plot.bat to make the plot.  

How to calculate the average value of multiple files  
1. Download and unzip the dataset, for example, objective-1-fast, from [here](https://media.xiph.org/video/derf/)  
2. select all the y4m files in the objective-1-fast folder and convert them with any preset.  
3. After all conversions are done, drop the objective-1-fast folder into csv_ave.bat and calculate the average value of csv  
4. In the objective-1-fast folder, a folder called objective-1-fast_benchmark_log is created, so drop that folder into plot.bat to make a plot  

How to calculate the BD-Rate  
1. Install Anaconda and set the Python path to environment variables  
2. Run "pip install Numpy matplotlib scipy" at the command prompt  
3. Drag and drop the benchmark_log folder to bd_rate.bat if you want to compare multiple codecs, or drag and drop the .bddata file to bd_rate.bat if you want to compare each preset of a specific encoder  
For more information about BD-Rate, see [this article](https://ottverse.com/what-is-bd-rate-bd-psnr-calculation-interpretation/).  

### important point  
When benchmarking with 10bit, rewrite ComparePixelFormat in video_benchmark.bat from yuv420p to yuv420p10le (even in the case of 8bit and 10bit mixed benchmarks)

If the fps of the video before encoding and the video after encoding are not aligned, the score such as SSIM will be measured abnormally low.  
Use a constant frame rate for the source video, not a variable frame rate.  