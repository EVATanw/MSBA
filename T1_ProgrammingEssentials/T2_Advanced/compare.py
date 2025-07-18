#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Dec 30 16:59:03 2024

@author: monster
"""

import timeit


def algorithm1_dataframe_time():
    SETUP_CODE = """
import pandas as pd
    
def read_txt_as_df(filepath, delimit):
    df = pd.read_csv(filepath, delimiter = delimit)
    return df

electricity = read_txt_as_df('./Electricity.txt', ';')
area = read_txt_as_df('./Area.txt', ';')
datadim = read_txt_as_df('./DateDim.txt', ';')
dwelling = read_txt_as_df('./Dwelling.txt', ',')

def leftmerge(left, right, leftkey, rightkey):
    merged = left.merge(right, 
                        how='left', 
                        left_on = leftkey,
                        right_on = rightkey)
    return merged
    """
    
    TEST_CODE = """
    
merged1 = leftmerge(electricity, datadim, 'DateID', 'DateID')
merged2 = leftmerge(merged1, area, 'AreaID', 'AreaID')
merged3 = leftmerge(merged2, dwelling, 'dwelling_type_id', 'TypeID')

merged_final = merged3[['Region','Area','year','month','dwelling_type','kwh_per_acc']]

    """
    
    times = timeit.repeat(setup = SETUP_CODE,
						stmt = TEST_CODE,
						repeat = 3,
						number = 100)

    print('Merge by algorithm1 dataframe time: {}'.format(min(times)))	

def algorithm2_dictionary_time():
    SETUP_CODE = """
import copy

def read_txt_as_dict(file_path, delimit):    
    with open(file_path, 'r') as file:
        headers = file.readline().strip().split(delimit)
        dictionary = {}
        for idx, line in enumerate(file, 1):
            key = str(idx)
            values = line.strip().split(delimit)
            value = {headers[i]: values[i] for i in range(len(headers))}
            dictionary[key] = value            
    return dictionary

electricity_dict = read_txt_as_dict("./Electricity.txt", ';')
area_dict = read_txt_as_dict("./Area.txt", ';')
datadim_dict = read_txt_as_dict("./DateDim.txt", ';')
dwelling_dict = read_txt_as_dict("./Dwelling.txt", ',')

def merge_dict(dict1, dict2, dict3, dict4):
    merged = copy.deepcopy(dict1)
    for key, value in merged.items():
        area_id = value['AreaID']
        date_id = value['DateID']
        dwelling_id = value['dwelling_type_id']
        if area_id in dict2:
            #value['Area_info'] = dict2[area_id]
            area_info = dict2[area_id]
            value['Area'] = area_info['Area']
            value['Region'] = area_info['Region']
            del value['AreaID']
        if date_id in dict3:
            #value['Date_info'] = dict3[date_id]
            date_info = dict3[date_id]
            value['year'] = date_info['year']
            value['month'] = date_info['month']
            del value['DateID']
        if dwelling_id in dict4:
            #value['Dwelling_info'] = dict4[dwelling_id]
            dwelling_info = dict4[dwelling_id]
            value['dwelling_type'] = dwelling_info['dwelling_type']
            del value['dwelling_type_id']
    return merged
    """
    
    TEST_CODE = """
result = merge_dict(electricity_dict, area_dict, datadim_dict, dwelling_dict)
    """
    
    times = timeit.repeat(setup = SETUP_CODE,
						stmt = TEST_CODE,
						repeat = 3,
						number = 100)

    print('Merge by algorithm2 dictionary time: {}'.format(min(times)))	

if __name__ == "__main__":
    algorithm1_dataframe_time()
    algorithm2_dictionary_time() 




