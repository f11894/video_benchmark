import numpy as np
import os
import csv
import glob
import sys

os.chdir(sys.argv[1])

DataSetName = 'objective-1-fast'
codec_array = ['x264_placebo_tunessim_crf32-18', 'x265_medium_tunessim_crf32-18', 'SVT-AV1_20190607_2fb6ab8_encmode8_q59-35']
metric_array = ['PSNR_Y', 'PSNR_Average', 'SSIM_Y', 'SSIM_All', 'VMAF', 'MS-SSIM', 'fps' , 'Time']
BitDepth_array = ['8bit', '10bit', 'Unspecified']
size_array = ['', '_bpp']

for size in size_array:
   for codec in codec_array:
      for BitDepth in BitDepth_array:
         for metric in metric_array:
            csv_Num = 0 #csvファイル数
            csvFileExist = False
            sum_val = np.zeros(1) #足し算の結果を入れる変数を用意
            exist_dir = os.path.isdir(DataSetName + '_benchmark_log')
            if not exist_dir:
               os.mkdir(DataSetName + '_benchmark_log')
            exist_file = os.path.isfile(DataSetName + '_benchmark_log/' + DataSetName + '_' + codec + '_' + metric + '(' + BitDepth + ')' + size + '.csv')
            if exist_file:
               os.remove(DataSetName + '_benchmark_log/' + DataSetName + '_' + codec + '_' + metric + '(' + BitDepth + ')' + size + '.csv')
            csv_list = glob.glob('*/*' + codec + '_' + metric + '(' + BitDepth + ')' + size + '.csv')
            for path in csv_list:
               csvFileExist = True
               print(path)
               data = np.loadtxt(path,comments='#' ,delimiter=',' )
               sum_val = sum_val + data
               csv_Num = csv_Num + 1
            if csvFileExist:
               ave_val = sum_val / csv_Num
               with open(DataSetName + '_benchmark_log/' + DataSetName + '_' + codec + '_' + metric + '(' + BitDepth + ')' + size + '.csv', 'a') as file:
                  writer = csv.writer(file, lineterminator='\n')
                  writer.writerows(ave_val)
