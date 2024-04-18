import pandas as pd
import os

from parse_file_functions import *

folder = "E:/Digital_Twin_and_UAM/ATFM_code/Vertiport_schedule/misc/Throughput"
outFolder = "E:/Digital_Twin_and_UAM/ATFM_code/Vertiport_schedule/misc/"
outFilename = "dep_throughput.csv"

# List the CSV files in the directory
csv_files = [file for file in os.listdir(folder) if (file.endswith('.csv') and "sol" in file)]

csv_files = [
"flight_sol_20_2023_11_17_23_50_07.csv",
"flight_sol_40_2023_11_18_00_02_30.csv",
"flight_sol_60_2023_11_18_00_06_05.csv",
"flight_sol_80_2023_11_18_21_14_09.csv",
"flight_sol_100_2023_10_26_10_44_51.csv",
"flight_sol_20_2023_11_17_23_51_19.csv",
"flight_sol_40_2023_11_18_00_00_02.csv",
"flight_sol_60_2023_11_18_00_14_19.csv",
"flight_sol_80_2023_11_19_10_24_07.csv",
"flight_sol_100_2023_11_22_21_12_51.csv",
"flight_sol_20_2023_11_17_23_52_46.csv",
"flight_sol_40_2023_11_17_23_58_07.csv",
"flight_sol_60_2023_11_18_00_21_56.csv",
"flight_sol_80_2023_11_19_22_33_32.csv",
"flight_sol_100_2023_11_23_03_09_04.csv",
"flight_sol_20_2023_11_17_23_53_51.csv",
"flight_sol_40_2023_11_17_23_55_39.csv",
"flight_sol_60_2023_11_18_00_54_31.csv",
"flight_sol_80_2023_11_20_11_56_03.csv",
"flight_sol_100_2023_11_23_11_02_44.csv",
]

#combined_data = throughput(csv_files, folder)
combined_data = combined_delay(csv_files, folder)


# Write the combined data to a new CSV file
combined_data.to_csv(outFolder + "/" + outFilename + '.csv', index=False)
