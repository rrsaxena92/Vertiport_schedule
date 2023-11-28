import os
import pandas as pd 
import numpy as np

def combined_delay(csv_files, folder):
    # Initialize an empty DataFrame for the combined data
    combined_data = pd.DataFrame(columns=['Num_flights', 'Num_directions', 'Delay'])

    # Iterate over each CSV file
    for file in csv_files:
        
        file_path = folder + "/" + file
        print(file_path)
        # Read the CSV file
        data = pd.read_csv(file_path)

        # Count the number of flights (unique names)
        num_flights = len(data['name'].unique())

        # Count the number of unique directions
        # Append the two columns into a single series
        dep_fix_direction = data['DepFix_direction']
        arr_fix_direction = data['ArrFix_direction']
        appended_series = dep_fix_direction.append(arr_fix_direction, ignore_index=True)

        # Remove values 0 and 'nan' from the series
        fix_directions = appended_series[(appended_series != '0') & (~pd.isna(appended_series))]

        # num_directions = len(data['fix_direction'].unique())
        num_directions = len(fix_directions.unique())

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
    
    return combined_data
    

def calculate_avg_TLOF_time(arr_tlof_time, dep_tlof_time):
    # Combine non-zero ArrTLOFtime and DepTLOFtime into a single array and sort it
    combined_tlof_time = np.sort(np.concatenate([arr_tlof_time[arr_tlof_time != 0], dep_tlof_time[dep_tlof_time != 0]]))

    # Calculate consecutive differences
    consecutive_diff = np.diff(combined_tlof_time)

    # Calculate average of consecutive differences
    avg_tlof_time = np.mean(consecutive_diff)
    return avg_tlof_time

def throughput(csv_files, folder):
    
    # Initialize an empty DataFrame for the combined data
    combined_data = pd.DataFrame(columns=['Num_flights', 'Num_directions', 'Type', 'Avg_TLOF_time', 'Throughput'])

    # Iterate over each CSV file
    for file in csv_files:
        file_path = folder + "/" + file
        
        print(file_path)
        # Read the CSV file into a DataFrame
        df = pd.read_csv(file_path)

        # Number of flights
        num_flights = len(df)

        # Number of unique directions removing Nan and 0 values 
        num_directions = len(pd.concat([df['ArrFix_direction'][df['ArrFix_direction']!=0], df['DepFix_direction'][df['DepFix_direction']!=0]]).dropna().unique())

        # Types among arr, dep, tat
        types = df['type'].unique()

        # Calculate average TLOF time
        avg_tlof_time = calculate_avg_TLOF_time(df['ArrTLOFtime'].values, df['DepTLOFtime'].values)
        throughput = int(np.floor(60/avg_tlof_time))

        # Create a new DataFrame with the extracted information
        file_data = pd.DataFrame({'Num_flights': num_flights,
                                  'Num_directions': num_directions,
                                  'Type': types,
                                  'Avg_TLOF_time': avg_tlof_time,
                                  'Throughput': throughput})

        # Append the file data to the combined data
        combined_data = combined_data.append(file_data, ignore_index=True)

    # sort Values according to Num flights then directions
    combined_data.sort_values(by=["Num_flights", "Num_directions"], inplace=True)
    
    return combined_data
