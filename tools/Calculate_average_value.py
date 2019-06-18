import numpy as np
import os
import csv
import glob
import sys
import argparse
parser = argparse.ArgumentParser() 

parser.add_argument('-i', '--input-dir', required=True, help='input dir')
parser.add_argument('-c', '--csv-name', nargs='*', required=True, help='csv name')
parser.add_argument('-d', '--dataset-name', required=True, help='dataset name')
args = parser.parse_args()

os.chdir(args.input_dir)

DataSetName = args.dataset_name
codec_array = args.csv_name
metric_array = ['PSNR_Y', 'PSNR_Average', 'SSIM_Y', 'SSIM_All', 'VMAF', 'MS-SSIM', 'fps' , 'Time']
BitDepth_array = ['8bit', '10bit', 'Unspecified']
size_array = ['', '_bpp']

for codec in codec_array:
   for size in size_array:
      for BitDepth in BitDepth_array:
         for metric in metric_array:
            csv_Num = 0
            csvFileExist = False
            sum_val = np.zeros(1)
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
               print('\n' + 'Calculate the average of these ' + str(csv_Num) + ' csv.\n\n\n')
               ave_val = sum_val / csv_Num
               with open(DataSetName + '_benchmark_log/' + DataSetName + '_' + codec + '_' + metric + '(' + BitDepth + ')' + size + '.csv', 'a') as file:
                  writer = csv.writer(file, lineterminator='\n')
                  writer.writerows(ave_val)
