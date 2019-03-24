import csv
import re

# linux version

f_in = open('/Users/sarora/dev/EAGER/data/orgs/firms_with_no_urls.csv')
csv_in = csv.reader(f_in)

f_out = open('/Users/sarora/dev/EAGER/data/orgs/tmp_cleaning/firms_with_no_urls_clnd.csv', 'w')
csv_out = csv.writer(f_out)

for row in csv_in:
    firm = row[0]
    firm_clnd = re.sub('(\.|,| corporation| incorporated| llc| inc| international| gmbh| ltd)', '', firm, flags=re.IGNORECASE).rstrip()
    csv_out.writerow([firm_clnd])
