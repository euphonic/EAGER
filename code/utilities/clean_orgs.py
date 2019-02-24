import csv
import re

# windows version

f_in = open('data\\orgs\\tmp_cleaning\\from-v5.csv')
csv_in = csv.reader(f_in)

f_out = open('data\\orgs\\tmp_cleaning\\to-v5.csv', 'w')
csv_out = csv.writer(f_out)

for row in csv_in:
    firm = row[0]
    firm_clnd = re.sub('(\.|,| corporation| incorporated| llc| inc| international| gmbh| ltd)', '', firm, flags=re.IGNORECASE).rstrip()
    csv_out.writerow(firm_clnd)
