# -*- coding: utf-8 -*-
"""
Created on Thu Nov 28 21:55:49 2024

@author: Tan Puay Meng G2401148D
"""
import pandas as pd
import timeit
import random
import matplotlib.pyplot as plt

# ElectricityUsage class
class ElectricityUsage:
    def __init__(self, region, area, year, month, dwelling_type, average_kwh_per_acc):
        self.region = region
        self.area = area
        self.year = year
        self.month = month
        self.dwelling_type = dwelling_type
        self.average_kwh_per_acc = average_kwh_per_acc
        
    def __repr__(self):
        return (f"Electrical Usage:(region='{self.region}', area='{self.area}', year='{self.year}', month='{self.month}' ,dwelling_type='{self.dwelling_type}', average_usage='{self.average_kwh_per_acc}')")


# Function to merge data using DataFrames
def merge_data_dataframe(area_data, dwelling_data, electricity_data, datedim_data):
    merge_table = (electricity_data
                  .merge(datedim_data, on="DateID", how="left")
                  .merge(area_data, on="AreaID", how="left")
                  .merge(dwelling_data, left_on="dwelling_type_id", right_on="TypeID", how="left"))

    return [ElectricityUsage(row['Region'], row['Area'], row['year'], row['month'], row['dwelling_type'], row['kwh_per_acc']) 
            for _, row in merge_table.iterrows()]

# Function to merge data using List
def merge_data_list(area_data, dwelling_data, electricity_data, datedim_data):
    merged_data = []
    for elec_row in electricity_data:
        area_id = elec_row['AreaID']
        dwelling_type_id = elec_row['dwelling_type_id']
        date_id = elec_row['DateID']

        #Find matching rows in other lists (This part can be improved for efficiency with dictionaries or pandas)
        area_match = next((area for area in area_data if area['AreaID'] == area_id), None)
        dwelling_match = next((dwelling for dwelling in dwelling_data if dwelling['TypeID'] == dwelling_type_id), None)
        date_match = next((date for date in datedim_data if date['DateID'] == date_id), None)

        if area_match and dwelling_match and date_match:
            merged_data.append(ElectricityUsage(
                region = area_match['Region'],
                area = area_match['Area'],
                year = date_match['year'],
                month =date_match['month'],
                dwelling_type = dwelling_match['dwelling_type'],
                average_kwh_per_acc= elec_row['kwh_per_acc']
            ))

    return merged_data

# Function to generate mock dataframe data
def generate_mock_dataframe_data(N):
    area_data = pd.DataFrame({
        'AreaID': [str(i) for i in range(N)],
        'Region': ['Region' + str(i % 5) for i in range(N)],
        'Area': ['Area' + str(i) for i in range(N)]
    })
    dwelling_data = pd.DataFrame({
        'TypeID': [str(i % 10) for i in range(N)],
        'dwelling_type': ['Type' + str(i % 10) for i in range(N)]
    })
    electricity_data = pd.DataFrame({
        'DateID': [str(i) for i in range(N)],
        'AreaID': [str(i % N) for i in range(N)],
        'dwelling_type_id': [str(i % 10) for i in range(N)],
        'kwh_per_acc': [random.uniform(50, 200) for _ in range(N)]
    })
    datedim_data = pd.DataFrame({
        'DateID': [str(i) for i in range(N)],
        'year': ['2024'] * N,
        'month': [str((i % 12) + 1) for i in range(N)]
    })
    return area_data, dwelling_data, electricity_data, datedim_data

# Function to generate mock list data
def generate_mock_list_data(N: int):
    area_data = [{'AreaID': str(i), 'Region': 'Region' + str(i % 5), 'Area': 'Area' + str(i)} for i in range(N)]
    dwelling_data = [{'TypeID': str(i % 10), 'dwelling_type': 'Type' + str(i % 10)} for i in range(N)]
    electricity_data = [{'DateID': str(i), 'AreaID': str(i % N), 'dwelling_type_id': str(i % 10), 'kwh_per_acc': str(random.uniform(50, 200))} for i in range(N)]
    datedim_data = [{'DateID': str(i), 'year': '2024', 'month': str(i % 12 + 1)} for i in range(N)]
    return area_data, dwelling_data, electricity_data, datedim_data


# Time Complexity Measurement for Dataframe
def time_merge_data_dataframe(sizes):
    execution_times = []
    for N in sizes:
        setup_code = f'''
from __main__ import generate_mock_dataframe_data, merge_data_dataframe
area_data, dwelling_data, electricity_data, datedim_data = generate_mock_dataframe_data({N})
'''

        test_code = '''
merge_data_dataframe(area_data, dwelling_data, electricity_data, datedim_data)
'''

        # Measure execution time
        times = timeit.repeat(setup=setup_code, stmt=test_code, repeat=10, number=1)
        avg_time = sum(times) / len(times)  # Take the average of the number of repetitions
        print(f"Data Size: {N}, Average Execution Time for DF: {avg_time:.6f} seconds")
        execution_times.append(avg_time)

    return execution_times

# Time Complexity Measurement for List
def time_merge_data_list(sizes):
    execution_times = []
    for N in sizes:
        setup_code = f'''
from __main__ import generate_mock_list_data, merge_data_list
area_data, dwelling_data, electricity_data, datedim_data = generate_mock_list_data({N})
'''

        test_code = '''
merge_data_list(area_data, dwelling_data, electricity_data, datedim_data)
'''
        # Measure execution time
        times = timeit.repeat(setup=setup_code, stmt=test_code, repeat=10, number=1)
        avg_time = sum(times) / len(times)  # Take the average of the number of repetitions
        print(f"Data Size: {N}, Average Execution Time for List: {avg_time:.6f} seconds")
        execution_times.append(avg_time)

    return execution_times

# plot function to compare the time for merging using List and Dataframe
def plot_performance(sizes, times_dataframe, times_list):
    plt.figure(figsize=(10, 6))
    
    # Plot DataFrame performance
    plt.plot(sizes, times_dataframe, marker='o', linestyle='-', label="DataFrame", color='b')
    
    # Plot List performance
    plt.plot(sizes, times_list, marker='o', linestyle='--', label="List", color='r')
    
    # Add title and labels
    plt.title("Performance Comparison: DataFrame vs List")
    plt.xlabel("Input Size (N)")
    plt.ylabel("Execution Time (seconds)")
    
    # Add grid and legend
    plt.grid(True)
    plt.legend()
    
    # Show the plot
    plt.show()

if __name__ == "__main__":
    sizes = [10, 100, 300]
    times_dataframe = time_merge_data_dataframe(sizes)
    times_list = time_merge_data_list(sizes)    

    # Plot both performances on the same graph
    plot_performance(sizes, times_dataframe, times_list)

    
