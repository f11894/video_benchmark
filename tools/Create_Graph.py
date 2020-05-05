import numpy as np
import matplotlib.pyplot as plt
import glob
import sys
import re
import os
import matplotlib.font_manager

font_prop = matplotlib.font_manager.FontProperties(fname=r'C:\Windows\Fonts\YuGothM.ttc')
os.chdir(sys.argv[1])
input = os.path.basename(sys.argv[1])
input = input.replace('_benchmark_log','')
BitDepth_array = ['8bit', '10bit', 'Unspecified']
markers = [ 'o', 'v', '^', '<', '>' , 's', 'D', 'd', 'p', '*', 'h', 'H', '+', 'x', '|', '_' , '.', ',', '8', '1', '2', '3', '4' ]
metric_array = ['PSNR_Y', 'PSNR_Average', 'SSIM_Y', 'SSIM_All', 'VMAF', 'MS-SSIM', 'fps' , 'Sec']
size_array = ['', '_bpp']

for size in size_array:
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
             if size == '':
                x_txt = data[:,0]
             else:
                x_txt = data[:,1]
             y_txt = data[:,row]
             plt.plot(x_txt,y_txt , label = codec_name , marker=markers[MNum])
             MNum = MNum + 1
         if csvFileExist:
             plt.title(input, fontproperties=font_prop)
             if size == '_bpp':
                plt.xlabel("bpp", fontproperties=font_prop)
             else:
             	plt.xlabel("bitrate(kbps)", fontproperties=font_prop)
             if metric == 'PSNR_Y' or metric == 'PSNR_Average':
                plt.ylabel(metric + ' (dB)', fontproperties=font_prop)
             else:
                if metric == 'Sec':
                   plt.ylabel('Elapsed Time (sec)', fontproperties=font_prop)
                else:
                   plt.ylabel(metric, fontproperties=font_prop)
             plt.grid(True,linestyle='dashed')
             if metric == 'PSNR_Y' or metric == 'PSNR_Average' or metric == 'SSIM_Y' or metric == 'SSIM_All' or metric == 'VMAF' or metric == 'MS-SSIM':
             	  plt.legend(loc='lower right', prop=font_prop)
             else:
                plt.legend(bbox_to_anchor=(1.01, 1), loc='upper left', borderaxespad=0, prop=font_prop)
             plt.savefig(input + '_' +  metric + '(' + BitDepth + ')' + size + '_Graph.png' ,  bbox_inches='tight')
         plt.close()
         row = row + 1
