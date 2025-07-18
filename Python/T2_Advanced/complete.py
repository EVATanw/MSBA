#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Dec 30 16:59:36 2024

@author: monster
"""

import pandas as pd

class MergeData():
    def read_txt_as_df(self, filepath, delimit):
        df = pd.read_csv(filepath, delimiter = delimit)
        return df
    
    def leftmerge(self, left, right, leftkey, rightkey):
        merged = left.merge(right, 
                        how='left', 
                        left_on = leftkey,
                        right_on = rightkey)
        return merged



if __name__ == "__main__" :
    
    algor = MergeData()
    
    electricity_df = algor.read_txt_as_df("/Users/monster/Desktop/dobby/NTU_BA/T2_AY2024/6007AdvancedProgramming/IA/Electricity.txt", ';')
    area_df = algor.read_txt_as_df("/Users/monster/Desktop/dobby/NTU_BA/T2_AY2024/6007AdvancedProgramming/IA/Area.txt", ';')
    datadim_df = algor.read_txt_as_df("/Users/monster/Desktop/dobby/NTU_BA/T2_AY2024/6007AdvancedProgramming/IA/DateDim.txt", ';')
    dwelling_df = algor.read_txt_as_df("/Users/monster/Desktop/dobby/NTU_BA/T2_AY2024/6007AdvancedProgramming/IA/Dwelling.txt", ',')
    merged1_df = algor.leftmerge(electricity_df, datadim_df, 'DateID', 'DateID')
    merged2_df = algor.leftmerge(merged1_df, area_df, 'AreaID', 'AreaID')
    merged3_df = algor.leftmerge(merged2_df, dwelling_df, 'dwelling_type_id', 'TypeID')
    merged_final = merged3_df[['Region','Area','year','month','dwelling_type','kwh_per_acc']]
    
    print(merged_final)
    
    
    
