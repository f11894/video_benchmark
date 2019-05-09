import numpy as np
import matplotlib.pyplot as plt
import glob
import sys
import re

input = sys.argv[1]
input = input.replace('_benchmark_log','')
BitDepth = sys.argv[2]
markers = [ 'o', 'v', '^', '<', '>' , 's', 'D', 'd', 'p', '*', 'h', 'H', '+', 'x', '|', '_' , '.', ',', '8', '1', '2', '3', '4' ]

metric_array = ['PSNR_Y', 'PSNR_Average', 'SSIM_Y', 'SSIM_All', 'VMAF', 'FPS' , 'Time']
for metric in metric_array:
   csv_list = glob.glob('*_' + metric + '(' + BitDepth + ').csv')
   plt.figure(figsize=(12, 8))
   csvFileExist = False
   MNum = 0
   for csv_name in csv_list:
       csvFileExist = True
       codec_name = csv_name
       codec_name = re.sub(input + '_' + '(.+)' + '_' + metric + '\(' + BitDepth + '\)\.csv','\\1',codec_name)
       data = np.loadtxt(csv_name ,comments='#' ,dtype='float' ,delimiter=',')
       x_txt = data[:,0]
       y_txt = data[:,1]
       plt.plot(x_txt,y_txt , label = codec_name , marker=markers[MNum])
       MNum = MNum + 1
   if csvFileExist:
       plt.title(input)
       plt.xlabel("bitrate(kbps)")
       if metric == 'PSNR_Y' or metric == 'PSNR_Average':
          plt.ylabel(metric + ' (dB)')
       else:
       	  if metric == 'Time':
              plt.ylabel(metric + ' (sec)')
          else:
             plt.ylabel(metric)
       plt.grid(True,linestyle='dashed')
       if metric == 'PSNR_Y' or metric == 'PSNR_Average' or metric == 'SSIM_Y' or metric == 'SSIM_All' or metric == 'VMAF':
       	  plt.legend(loc='lower right')
       else:
          plt.legend(bbox_to_anchor=(1.01, 1), loc='upper left', borderaxespad=0)
       plt.savefig(input + '_' +  metric + '(' + BitDepth + ')_Graph.png' ,  bbox_inches='tight')
   plt.close()
