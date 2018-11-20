import csv
import re

f_in = open('data\\patents\\assignee_clnd.csv')
csv_in = csv.reader(f_in)

f_out = open('data\\patents\\assignee_clnd2.csv', 'w')
csv_out = csv.writer(f_out)

for row in csv_in:
    firm = row[4]
    firm_clnd = re.sub('(\.|,| corporation| incorporated| llc| inc| international| gmbh| ltd)', '', firm, flags=re.IGNORECASE).rstrip()
    csv_out.writerow([row[0], row[1], row[2], row[3], firm, firm_clnd])