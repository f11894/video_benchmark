import numpy as np
import matplotlib.pyplot as plt
import glob
import sys
import re
import os
from matplotlib import rcParams
import matplotlib.ticker

rcParams['font.family'] = 'sans-serif'
rcParams['font.sans-serif'] = ['Meiryo', 'Yu Gothic', 'DejaVu Sans']
os.chdir(sys.argv[1])
input = os.path.basename(sys.argv[1])
input = input.replace('_benchmark_log','')
BitDepth_array = ['8bit', '10bit', 'Unspecified']
markers = [ 'o', 'v', '^', '<', '>' , 's', 'D', 'd', 'p', '*', 'h', 'H', '+', 'x', '|', '_' , '.', ',', '8', '1', '2', '3', '4' ]
metric_array = ['PSNR_Y', 'PSNR_Average', 'SSIM_Y', 'SSIM_All', 'VMAF', 'XPSNR_Y', 'fps' , 'Sec']

for BitDepth in BitDepth_array:
   row = 2
   for metric in metric_array:
      csv_list = glob.glob('*_'  + '(' + BitDepth + ').csv')
      plt.figure(figsize=(12, 8))
      csvFileExist = False
      MNum = 0
      for csv_name in csv_list:
          csvFileExist = True
          codec_name = csv_name
          codec_name = csv_name.replace(input,'')
          codec_name = re.sub('_' + '(.+)' + '_'  + '\(' + BitDepth + '\)\.csv','\\1',codec_name)
          data = np.loadtxt(csv_name ,comments='#' ,dtype='float' ,delimiter=',',  skiprows=1, usecols=(1,2,3,4,5,6,7,8,9,10), encoding='utf-8')
          x_txt = data[:,0]
          y_txt = data[:,row]
          plt.plot(x_txt,y_txt , label = codec_name , marker=markers[MNum])
          MNum = MNum + 1
      if csvFileExist:
          plt.title(input)
          plt.xlabel("bitrate(kbps)")
          if metric == 'PSNR_Y' or metric == 'PSNR_Average':
             plt.ylabel(metric + ' (dB)')
          else:
             if metric == 'Sec':
                plt.ylabel('Elapsed Time (sec)')
             else:
                plt.ylabel(metric)
          plt.grid(True,linestyle='dashed')
          if metric == 'PSNR_Y' or metric == 'PSNR_Average' or metric == 'SSIM_Y' or metric == 'SSIM_All' or metric == 'VMAF' or metric == 'XPSNR_Y':
          	  plt.legend(loc='lower right')
          	  plt.savefig(input + '_' +  metric + '(' + BitDepth + ')'  + '_Graph.png' ,  bbox_inches='tight')
          else:
             plt.legend(bbox_to_anchor=(1.01, 1), loc='upper left', borderaxespad=0)
             plt.savefig(input + '_' +  metric + '(' + BitDepth + ')'  + '_Graph.png' ,  bbox_inches='tight')
             plt.yscale('log')
             plt.gca().yaxis.set_major_formatter(matplotlib.ticker.ScalarFormatter())
             plt.savefig(input + '_' +  metric + '(' + BitDepth + ')'  + '_log_Graph.png' ,  bbox_inches='tight')
      plt.close()
      row = row + 1
