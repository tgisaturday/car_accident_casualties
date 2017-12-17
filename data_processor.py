import re
import sys
import os
import numpy as np
import pandas as pd

df1 = pd.read_csv('2012-2014.csv',encoding = 'ANSI')
df2 = pd.read_csv('2015.csv',encoding = 'ANSI')
df3 = pd.read_csv('2016.csv',encoding = 'ANSI')

df = pd.concat([df1, df2, df3], ignore_index=True)

df =df.drop(["사망자수","발생분","요일","중상자수","발생지시군구","경상자수","부상신고자수","사고유형",
         "법규위반_대분류","법규위반","도로형태","당사자종별_1당_대분류","당사자종별_1당","당사자종별_2당_대분류",
         "당사자종별_2당","발생위치X_UTMK","발생위치Y_UTMK"],axis=1)

columns = ["year", "date", "day_night","casualty","city","accident_class","accident_subclass","road_type", "longitude","latitude"]
df.columns=columns

year = df["year"].tolist()
date = df["date"].tolist()
day_tmp = df["day_night"].tolist()
casualty =  df["casualty"].tolist()
city_tmp = df["city"].tolist()
accident_class_tmp = df["accident_class"].tolist()
accident_subclass_tmp = df["accident_subclass"].tolist()
road_type_tmp = df["road_type"].tolist()
longitude = df["longitude"].tolist()
latitude = df["latitude"].tolist()

day =[]
day_label = {}
count = 0
for data in day_tmp:
    if data not in day_label:
        day_label[data] = count
        count+=1
    day.append(day_label[data])

for i in range(len(casualty)):
    casualty[i] = int(casualty[i]/10) *10

city =[]
city_label = {}
count = 0
for data in city_tmp:
    if data not in city_label:
        city_label[data] = count
        count+=1
    city.append(city_label[data])

accident_class =[]
accident_class_label = {}
count = 0
for data in accident_class_tmp:
    if data not in accident_class_label:
        accident_class_label[data] = count
        count+=1
    accident_class.append(accident_class_label[data])

accident_subclass =[]
accident_subclass_label = {}
count = 0
for data in accident_subclass_tmp:
    if data not in accident_subclass_label:
        accident_subclass_label[data] = count
        count+=1
    accident_subclass.append(accident_subclass_label[data])

road_type =[]
road_type_label = {}
count = 0
for data in road_type_tmp:
    if data not in road_type_label:
        road_type_label[data] = count
        count+=1
    road_type.append(road_type_label[data])

fp = open("labels.txt","w")

print("1. day/night", file = fp)
for item in day_label:
    print(item+":", day_label[item],file = fp)
print(file = fp)    
print("2. city", file = fp)
for item in city_label:
    print(item+":", city_label[item],file = fp)
print(file = fp) 
print("3. accident_class", file = fp)
for item in accident_class_label:
    print(item+":", accident_class_label[item],file = fp)
print(file = fp) 
print("4. accident_subclass", file = fp)
for item in accident_subclass_label:
    print(item+":", accident_subclass_label[item],file = fp)
print(file = fp) 
print("5. road_type", file = fp)
for item in road_type_label:
    print(item+":", road_type_label[item],file = fp)
print(file = fp) 
fp.close()

data=[]
for i in range(len(day)):
    data.append([year[i],date[i],day[i],casualty[i],city[i],accident_class[i],accident_subclass[i],road_type[i],longitude[i],latitude[i]])
df_new = pd.DataFrame(data, columns = columns)
df_new.to_csv('accidents.csv', index=False, columns=columns, sep=',', encoding='ANSI')

fp = open("accidents.geojson","w")

geo_json = [ {"type": "Feature",
                   "properties": {
                     "casualty": cas},
                    "geometry": {
                        "type": "Point",
                        "coordinates": [lon,lat] }}
                    for cas, lon,lat in zip(casualty[0:10],longitude[0:10],latitude[0:10]) ]

print(geo_json,file=fp)

fp.close()












