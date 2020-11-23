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

bddata_list = glob.glob(DataSetName + '_benchmark_log/*.bddata')
for bddata_path in bddata_list:
	os.remove(bddata_path)

empty = ['']
BitDepth_array = ['8bit', '10bit', 'Unspecified']
header = ['Filename', 'bitrate', 'bpp', 'PSNR_Y', 'PSNR_Average', 'SSIM_Y', 'SSIM_All', 'VMAF', 'MS-SSIM', 'fps', 'Sec', 'CommandLine']
files = os.listdir(sys.argv[1])
files_dir = [f for f in files if os.path.isdir(os.path.join(sys.argv[1], f))]
for BitDepth in BitDepth_array:
    csv_list = glob.glob(files_dir[0] + '/*_(' + BitDepth + ').csv')
    for csv_path in csv_list:
        dir_name = files_dir[0].replace('_benchmark_log','')
        csv_name = csv_path
        csv_name = re.sub(dir_name + '_benchmark_log\\\\' + dir_name + '_(.+)' + '_'  + '\(.+\)\.csv','\\1',csv_name)
        codec_name = re.sub('([^_]+)_.+','\\1',csv_name)
        csv_suffix = re.sub('[^_]+_(.+)','\\1',csv_name)
        csv_Num = 0
        sum_value = np.zeros(1)
        csv_list2 = glob.glob('*/*' + csv_name + '_(' + BitDepth + ').csv')
        for path in csv_list2:
            data = np.loadtxt(path,comments='#' ,delimiter=',', skiprows=1, usecols=(1,2,3,4,5,6,7,8,9,10), encoding='utf-8')
            print('Import   ' + path)
            sum_value = sum_value + data
            csv_Num = csv_Num + 1
        ave_value = sum_value / csv_Num
        print('New file   ' + DataSetName + '_benchmark_log/' + DataSetName + '_' + csv_name + '_(' + BitDepth + ').csv\n')
        with open(DataSetName + '_benchmark_log/' + DataSetName + '_' + csv_name + '_(' + BitDepth + ').csv', 'w') as file:
            writer = csv.writer(file, lineterminator='\n')
            writer.writerow(header)
            for row in ave_value:
                corrected_row = np.concatenate([empty,row,empty])
                writer.writerow(corrected_row)
        with open(DataSetName + '_benchmark_log/' + DataSetName + '_' + csv_name + '_(' + BitDepth + ').csv') as f:
            h = next(csv.reader(f))
            for c in csv.reader(f):
                with open(DataSetName + '_benchmark_log/' + DataSetName + '_' + codec_name + '_(' + BitDepth + ').bddata', mode='a') as bddata:
                    bddata.write('(\'' + codec_name + '\', ' + c[10] + ', \'' + csv_suffix + '\', 0, ' + c[1] + ', ' + c[7] + ', ' + c[3] + ', ' + c[5] + ', ' + c[8] + '),')

for bddata_path in bddata_list:
    with open(bddata_path , mode='a') as bddata:
            bddata.write('\n')
