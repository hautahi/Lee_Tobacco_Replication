'''
clean TIMS data a la Lee et al. (2015) with 2016 TIMS data

chris zhang 3/29/2017
'''

import pandas as pd
from datetime import datetime

pd.set_option('display.max_columns', 999)
pd.set_option('display.width', 200)

## read FY2016, 2017 public inspection data
df = pd.read_csv('./data/OCE_FY2016.csv', encoding="ISO-8859-1")
df1 = pd.read_csv('./data/OCE_FY2017.csv', encoding="ISO-8859-1")
df = df.append(df1).reset_index(drop=True)

## filter out CY2016
L0 = len(df)
df['year'] = df['Decision Date'].apply(lambda x: datetime.strptime(x, '%m/%d/%Y').year)
df['month'] = df['Decision Date'].apply(lambda x: datetime.strptime(x, '%m/%d/%Y').month)
df['day'] = df['Decision Date'].apply(lambda x: datetime.strptime(x, '%m/%d/%Y').day)
df = df[(df.year==2016)]
print('%s inspections with Decision Date in calendar year 2016' % len(df))

## drop if  Minor Involved = No
L0 = len(df)
df = df[df['Minor Involved']=='Yes']
print('%s inspections dropped: Minor Involved=No' % (L0 - len(df)))


## drop if Decision Type is N/A
print('----------Decicison Type value counts-----------------------')
print(df['Decision Type'].value_counts())
print('%s inspections have reported Decision Type' % sum(df['Decision Type'].value_counts()))
print('%s inspections dropped: Decision Type = N/A' % (len(df) - sum(df['Decision Type'].value_counts())))
print('-------------------------------------------------------------')

## drop duplicates in terms of everything except for Decision Type/Minor Involved/Sale to Minor
L0 = len(df)
df = df.drop_duplicates(subset=['Street Address', 'City', 'State', 'Zip', 'year', 'month', 'day'], keep='first')
print('%s inspections dropped: duplicates' % (L0 - len(df)))

print('------- to further drop: inspections in Tracts with population <=100')
print('------- to further drop: inspections in Tracts without poverty data')

print('%s inspections remaining' % len(df))

del df['Link']
df.to_csv('./data/FDA2016.csv', index=False)
