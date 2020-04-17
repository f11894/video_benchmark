import numpy as np
import os
import csv
import glob
import sys
import re

os.chdir(sys.argv[1])
DataSetName = os.path.basename(sys.argv[1])
exist_dir = os.path.isdir(DataSetName + '_benchmark_log')
if not exist_dir:
    os.mkdir(DataSetName + '_benchmark_log')

BitDepth_array = ['8bit', '10bit', 'Unspecified']
header = ['bitrate', 'bpp', 'PSNR_Y', 'PSNR_Average', 'SSIM_Y', 'SSIM_All', 'VMAF', 'MS-SSIM', 'fps' , 'Sec']
files = os.listdir(sys.argv[1])
files_dir = [f for f in files if os.path.isdir(os.path.join(sys.argv[1], f))]
for BitDepth in BitDepth_array:
    csv_list = glob.glob(files_dir[0] + '/*_(' + BitDepth + ').csv')
    for csv_name in csv_list:
        dir_name = files_dir[0].replace('_benchmark_log','')
        codec_name = csv_name
        codec_name = re.sub(dir_name + '_benchmark_log\\\\' + dir_name + '_(.+)' + '_'  + '\(.+\)\.csv','\\1',codec_name)
        csv_Num = 0
        sum_value = np.zeros(1)
        csv_list2 = glob.glob('*/*' + codec_name + '_(' + BitDepth + ').csv')
        for path in csv_list2:
            data = np.loadtxt(path,comments='#' ,delimiter=',', skiprows=1)
            sum_value = sum_value + data
            csv_Num = csv_Num + 1
        ave = sum_value / csv_Num
        with open(DataSetName + '_benchmark_log/' + DataSetName + '_' + codec_name + '_(' + BitDepth + ').csv', 'w') as file:
            writer = csv.writer(file, lineterminator='\n')
            writer.writerow(header)
            writer.writerows(ave)
