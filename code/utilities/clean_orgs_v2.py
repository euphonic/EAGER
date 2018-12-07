import csv
import re

f_in = open('/Users/sarora/dev/EAGER/data/orgs/tmp_cleaning/small_firms.csv')
csv_in = csv.reader(f_in)

f_out = open('/Users/sarora/dev/EAGER/data/orgs/segments/small_firms.csv', 'w')
csv_out = csv.writer(f_out)

for row in csv_in:
    firm = row[0]
    firm_clnd = re.sub('(\.|,| corporation| incorporated| llc| inc| international| gmbh| ltd)', '', firm, flags=re.IGNORECASE).rstrip()
    csv_out.writerow([firm_clnd])