import pandas as pd
import os

folder = "E:/Digital_Twin_and_UAM/ATFM_code/Vertiport_schedule/misc/Matlab simulation for arrival 5,10,15,20 for dir 1,2,3,4"
outFolder = "E:/Digital_Twin_and_UAM/ATFM_code/Vertiport_schedule/misc/"
outFilename = "ArrivalsOnlyNoX"

# List the CSV files in the directory
csv_files = [file for file in os.listdir(folder) if file.endswith('.csv')]

# Initialize an empty DataFrame for the combined data
combined_data = pd.DataFrame(columns=['Num_flights', 'Num_directions', 'Delay'])

# Iterate over each CSV file
for file in csv_files:
    # Read the CSV file
    data = pd.read_csv(folder + "/" + file)

    # Count the number of flights (unique names)
    num_flights = len(data['name'].unique())

    # Count the number of unique directions
    num_directions = len(data['fix_direction'].unique())

    # Extract the 'delay' column as it is
    delay = data['delay']

    # Create a new DataFrame with the extracted information
    file_data = pd.DataFrame({'Num_flights': num_flights,
                              'Num_directions': num_directions,
                              'Delay': delay})

    # Append the file data to the combined data
    combined_data = combined_data.append(file_data, ignore_index=True)

# sort Values according to Num flights then directions
combined_data.sort_values(by=["Num_flights", "Num_directions"], inplace=True)

# Write the combined data to a new CSV file
combined_data.to_csv(outFolder + "/" + outFilename + '.csv', index=False)