import csv
import re

# windows version

f_in = open('/Users/sanjay/data/patentsview/20181127/final_lookup_firm.csv')
csv_in = csv.reader(f_in, delimiter=',')
next(csv_in, None)  # skip the headers

f_out = open('/Users/sanjay/data/patentsview/20181127/final_lookup_firm_clnd.csv', 'w')
csv_out = csv.writer(f_out, delimiter=',')

# csv_out.writerow(['id', 'type,' 'name_first', 'name_last', 'organization', 'organization_clnd'])

for row in csv_in:
    firm = row[0]
    firm_clnd = re.sub('(\.|,| corporation| incorporated| llc| inc| international| gmbh| ltd)', '', firm, flags=re.IGNORECASE).rstrip()
    out = []
    out.append(firm_clnd)
    csv_out.writerow(out)
