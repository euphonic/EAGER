# Compare input file with mongodb
# Sanjay K Arora
# November 2018

# 1. Look for input firm names (have this in chunks files)
# 2. Get the name of the collection (using the same code)
# 3. Query mongo to produce aggregate results (already have this)
# 4. Now do a diff, and print out how many pages if there is a match at the firm name

import csv
import pprint
import sys
import pprint
from urllib.parse import urlparse
from FirmDB.config import connection_string
from FirmDB.config import username
from FirmDB.config import password
from FirmDB.config import authSource
from FirmDB.config import authMechanism

CHUNK = sys.arg[0]
CHUNK_FILE = "../data/orgs/chunks/" + CHUNK + ".csv"
MONGODB_DB = "FirmDB"
MONGODB_COLLECTION = "pages_" + CHUNK

def get_firm_aggregates ():
    client = pymongo.MongoClient(connection_string, username=username, password=password, authSource=authSource, authMechanism=authMechanism)
    db = client[MONGODB_DB]
    col = db[MONGODB_COLLECTION]
    query = "[ { $group: {'_id':'$firm_name' , 'number':{$sum:1}} } ]"
    results = col.aggregate(query)
    pp = pprint.PrettyPrinter()
    pp.pprint(results)

    return results

def read_firms_csv(filename):
    """
    Parse CSV files that contain:
    firm, url
    and return a list of dictionaries representing the firms

    :param filename:
    :return:
    """
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

            # If no URL is available, don't append the school
            if firm['url'] == '': continue
            # Parse the website domain from the full URL
            firm['domain'] = urlparse(firm['url']).netloc
            firms.append(firm)

    pp = pprint.PrettyPrinter()
    pp.pprint(firms)

    return firms


if __name__ == "__main__":
    # Get the list of firms and domains
    # firms = read_firms_csv(CHUNK_FILE)
    # start_urls = [firm['url'] for firm in firms]
    # allowed_domains = [firm['domain'] for firm in firms]

    mongo_results = get_firm_aggregates ()


