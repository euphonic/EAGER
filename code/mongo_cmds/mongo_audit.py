# Compare input file with mongodb
# Sanjay K Arora
# November 2018

# 1. Look for input firm names (have this in chunks files)
# 2. Query mongo to produce aggregate results (already have this)
# 3. Now do a diff, and print out how many pages if there is a match at the firm name

# Input: Requires an input collection number, e.g., 1
# Output: A list of missing firms that need to be recrawled 

import csv
import pprint
import sys
import pprint
import pymongo
from urllib.parse import urlparse
from FirmDB.config import connection_string
from FirmDB.config import username
from FirmDB.config import password
from FirmDB.config import authSource
from FirmDB.config import authMechanism

CHUNK = sys.argv[1]
CHUNK_FILE = "../../data/orgs/chunks/" + CHUNK + ".csv"
MISSING_FILE = "../../data/orgs/chunks/" + CHUNK + "_missing.csv"
MONGODB_DB = "FirmDB"
MONGODB_COLLECTION = "pages_" + CHUNK

def get_firm_aggregates ():
    client = pymongo.MongoClient(connection_string, username=username, password=password, authSource=authSource, authMechanism=authMechanism)
    db = client[MONGODB_DB]
    col = db[MONGODB_COLLECTION]
    query = [ { "$group": {"_id":"$firm_name" , "number":{"$sum":1}} } ]
    results = col.aggregate(query)
    pp = pprint.PrettyPrinter()
    # pp.pprint(list(results))

    mongo_dict = {}
    for result in results:
        key = (result['_id'])
        if key:
            mongo_dict[key[0]] = result['number']
        else:
            mongo_dict['NA'] = result['number']
    
    # pp.pprint (mongo_dict)
    return mongo_dict

def read_firms_csv(filename):
    firms = []
    with open(filename) as csvfile:
        reader = csv.reader(csvfile, delimiter=',')
        # skip the header
        # next(reader)

        for row in reader:
            firm = {
                'firm_name': row[0],
                'url': row[1]
            }

            firm['domain'] = urlparse(firm['url']).netloc
            firms.append(firm)

    # pp = pprint.PrettyPrinter()
    # pp.pprint(firms)

    return firms

def compare (firms, mongo_results):
    f_out = open(MISSING_FILE, 'w')
    csv_out = csv.writer(f_out)
    for firm in firms:
        firm_name = firm['firm_name']
        if firm_name in mongo_results:
            print (firm_name + " in mongo with " + str(mongo_results[firm_name]) + " pages") 
        else:
            print (firm_name + " not in mongo")
            csv_out.writerow([firm_name, firm['url']])

# 1. 
firms = read_firms_csv(CHUNK_FILE)
# 2. 
mongo_results = get_firm_aggregates ()
# 3. 
compare(firms, mongo_results)
