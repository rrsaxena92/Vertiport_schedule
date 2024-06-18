import pandas as pd
import os

from parse_file_functions import *

folder = "E:/Digital_Twin_and_UAM/ATFM_code/Vertiport_schedule/misc/TimeBound"
outFolder = "E:/Digital_Twin_and_UAM/ATFM_code/Vertiport_schedule/misc/"
outFilename = "TimeBound_SmallSet1_Dir1.csv"

# List the CSV files in the directory
csv_files = [file for file in os.listdir(folder) if (file.endswith('.csv') and "sol" in file)]

csv_files = [
"flight_sol_20_2024_06_10_23_52_53.csv",
"flight_sol_20_2024_06_10_23_53_59.csv",
"flight_sol_20_2024_06_10_23_55_10.csv",
"flight_sol_20_2024_06_10_23_55_51.csv",
"flight_sol_20_2024_06_10_23_58_30.csv",
"flight_sol_40_2024_06_11_00_01_38.csv",
"flight_sol_40_2024_06_11_11_22_01.csv",
"flight_sol_40_2024_06_11_17_25_40.csv",
"flight_sol_40_2024_06_11_23_00_04.csv",
"flight_sol_40_2024_06_11_23_00_56.csv",
"flight_sol_60_2024_06_13_11_31_39.csv",
"flight_sol_60_2024_06_13_11_31_57.csv",
"flight_sol_60_2024_06_13_16_42_07.csv"
]

# combined_data = throughput(csv_files, folder)
# combined_data = combined_delay(csv_files, folder)
combined_data = combined_delay_bound(csv_files, folder)

# Write the combined data to a new CSV file
combined_data.to_csv(outFolder + "/" + outFilename, index=False)
