import csv
import sys
from pws import Bing
import requests
import re
import pprint
import pymongo
import traceback
from time import sleep
import requests

mdbc = pymongo.MongoClient("mongodb://localhost:27017/")
db = mdbc["EAGER"]
col = db["bingResults"]

f_in = open('/Users/sarora/dev/EAGER/data/orgs/companies.csv')
csv_in = csv.reader(f_in)

f_out = open('/Users/sarora/dev/EAGER/data/orgs/missing-from-mongo3.csv', 'w')
csv_out = csv.writer(f_out)

e_out = open('/Users/sarora/dev/EAGER/data/error_out.csv', 'w')
ecsv_out = csv.writer(e_out)

csv_out.writerow(["firm name", "frequency"])

for row in csv_in:
    firm = row[0]
    firm_regex = '^' + firm
    firm_regex = re.sub('\(', '\\(', firm_regex)
    firm_regex = re.sub('\)', '\\)', firm_regex)
    query = {"queryContext.originalQuery": re.compile(firm_regex, re.IGNORECASE) }
    print (query)
    results = col.find(query)

    if results.count() < 1:
        print(csv_out.writerow([firm, results.count()]))
    else:
        continue
