#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Dec 30 22:01:24 2024

@author: monster
"""

class Query():
    def __init__(self, data):
        self.year = self.q_year()
        self.month = self.q_month()
        self.region = self.q_region(data)
        self.area = self.q_area(data)
        self.type = self.q_type(data)         

    def q_year(self):
        q_year = int(input('Enter a year(2010~2023) you want to search: ').strip())
        return q_year
    
    def q_month(self):
        q_month = int(input('Enter a month you want to search: ').strip())
        return q_month   
    
    def q_region(self, data):
        t = self.check_region_number(data)
        options = "\n".join([f"{index}: {item}" for index, item in enumerate(t, start = 1)])
        prompt = f"Choose the number of region you want to search:\n{options}\n"
        q_region_num = int(input(prompt).strip())
        for index, item in enumerate(t,start=1):
            if index == q_region_num:
                return item    
    
    def q_area(self, data):
        t = self.check_area_number(data)
        options = "\n".join([f"{index}: {item}" for index, item in enumerate(t, start = 1)])
        prompt = f"Choose the number of area you want to search:\n{options}\n"
        q_area_num = int(input(prompt).strip())
        for index, item in enumerate(t,start=1):
            if index == q_area_num:
                return item    
        
    def q_type(self, data):
        t = self.check_dwelling_type_number(data)
        options = "\n".join([f"{index}: {item}" for index, item in enumerate(t, start = 1)])
        prompt = f"Choose the number of dwelling type you want to search:\n{options}\n"
        q_type_num = int(input(prompt).strip())
        for index, item in enumerate(t,start=1):
            if index == q_type_num:
                return item    
        
    def result(self, data):
        for key, value in data.items():
            if value['year'] == self.year \
            and value['month'] == self.month \
            and value['Region'] == self.region \
            and value['Area'] == self.area \
            and value['dwelling_type'] == self.type:
                result = value['kwh_per_acc']
                return f"The average household usage of electricity for {self.year}.{self.month}, {self.region}, {self.area}, and {self.type} is {result:.2f} kWh."
        return "No data found."

    def check_region_number(self, data):
        regions = set()
        for key, value in data.items():
            regions.add(value['Region'])
        return regions
            
    def check_area_number(self, data):
        areas = set()
        for key, value in data.items():
            areas.add(value['Area'])
        return areas
    
    def check_dwelling_type_number(self, data):
        types = set()
        for key, value in data.items():
            types.add(value['dwelling_type'])
        return types
    

if __name__ == "__main__" :
    
    while True:
        que = input('Do you want to search? yes/no').strip().lower()
        if que == 'yes':
            
            # merge data
            from complete import MergeData    
            algor = MergeData()
            
            electricity_df = algor.read_txt_as_df("/Users/monster/Desktop/dobby/NTU_BA/T2_AY2024/6007AdvancedProgramming/IA/Electricity.txt", ';')
            area_df = algor.read_txt_as_df("/Users/monster/Desktop/dobby/NTU_BA/T2_AY2024/6007AdvancedProgramming/IA/Area.txt", ';')
            datadim_df = algor.read_txt_as_df("/Users/monster/Desktop/dobby/NTU_BA/T2_AY2024/6007AdvancedProgramming/IA/DateDim.txt", ';')
            dwelling_df = algor.read_txt_as_df("/Users/monster/Desktop/dobby/NTU_BA/T2_AY2024/6007AdvancedProgramming/IA/Dwelling.txt", ',')
            merged1_df = algor.leftmerge(electricity_df, datadim_df, 'DateID', 'DateID')
            merged2_df = algor.leftmerge(merged1_df, area_df, 'AreaID', 'AreaID')
            merged3_df = algor.leftmerge(merged2_df, dwelling_df, 'dwelling_type_id', 'TypeID')
            merged_final = merged3_df[['Region','Area','year','month','dwelling_type','kwh_per_acc']]
            data_dict = merged_final.to_dict(orient='index')
            
            # query and answer    
            query = Query(data_dict)
            
            print(query.result(data_dict))
        else:
            break
    
    print("Thank you, bye bye.")
    













