import numpy as np
import matplotlib.pyplot as plt
import glob
import sys
import re

input = sys.argv[1]
input = input.replace('_benchmark_log','')
BitDepth = sys.argv[2]

metric_array = ['PSNR_Y', 'PSNR_Average', 'SSIM_Y', 'SSIM_All', 'VMAF']
for metric in metric_array:
   csv_list = glob.glob('*_' + metric + '(' + BitDepth + ').csv')
   plt.figure(figsize=(12, 8))
   csvFileExist = False
   for csv_name in csv_list:
       csvFileExist = True
       codec_name = csv_name
       codec_name = re.sub(input + '_' + '(.+)' + '_' + metric + '\(' + BitDepth + '\)\.csv','\\1',codec_name)
       data = np.loadtxt(csv_name ,comments='#' ,dtype='float' ,delimiter=',')
       x_txt = data[:,0]
       y_txt = data[:,1]
       plt.plot(x_txt,y_txt , label = codec_name)
       plt.scatter(x_txt,y_txt)
   if csvFileExist:
       plt.title(input)
       plt.xlabel("bitrate(kbps)")
       plt.ylabel(metric)
       plt.grid(True,linestyle='dashed')
       plt.legend(loc='lower right')
       plt.savefig(input + '_' +  metric + '(' + BitDepth + ')_Graph.png')
   plt.close()
