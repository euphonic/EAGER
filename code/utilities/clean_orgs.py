import csv
import re

f_in = open('/Users/sarora/dev/EAGER/data/linkedin/linkedin_orgs.txt')
csv_in = csv.reader(f_in)

for row in csv_in:
    firm = row[0]
    firm_clnd = re.sub('(\.|,| corporation| incorporated| llc| inc| international| gmbh| ltd)', '', firm, flags=re.IGNORECASE).rstrip()
    print (firm_clnd)
