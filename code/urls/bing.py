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
from config import connection_string
from config import username
from config import password
from config import authSource
from config import authMechanism

mdbc = pymongo.MongoClient(connection_string, username=username, password=password, authSource=authSource, authMechanism=authMechanism)
db = mdbc["EAGER"]
col = db["bingResults"]

pp = pprint.PrettyPrinter(indent=4)

f_in = open('/home/eager/EAGER/data/orgs/workshop/all_demo.csv')
csv_in = csv.reader(f_in)

e_out = open('/home/eager/EAGER/data/error_out.csv', 'w')
ecsv_out = csv.writer(e_out)

subscription_key = "b955f2b5212a44589d84e7b1b7e9bb6b"
assert subscription_key
search_url = "https://api.cognitive.microsoft.com/bing/v7.0/search"
HITNUM = 8 # the number of search results to process for a given firm

for row in csv_in:
    firm = row[0]
    firm_clnd = re.sub('(\.|,| corporation| incorporated| llc| inc| international| gmbh| ltd)', '', firm, flags=re.IGNORECASE).rstrip()
    if len(firm_clnd) <= 2:
        firm_clnd = firm

    firm_length = len(firm_clnd)
    firm_regex = '^' + firm_clnd + '$'
    firm_regex = re.sub('\(', '\\(', firm_regex)
    firm_regex = re.sub('\)', '\\)', firm_regex)
    query = {"queryContext.originalQuery": re.compile(firm_regex, re.IGNORECASE) }
    results = col.find(query)

    if results.count() > 0:
        # print("Skipping " + firm + " because already in mongo.")
        continue

    search_term = firm_clnd
    print("Working on ", search_term)
    s = requests.Session()

    headers = {"Ocp-Apim-Subscription-Key": subscription_key}
    params = {"q": search_term, "textDecorations": True, "textFormat": "Raw"}

    try:
        response = requests.get(search_url, headers=headers, params=params)
        response.raise_for_status()
        results = response.json()

        hits = results['webPages']['value']

        # pp = pprint.PrettyPrinter()
        # pp.pprint(hits)

        link = None

        for i in range(HITNUM):
            hit = hits[i]
            link = hit['url']
            name = hit['name']
            snippet = hit['snippet']
            if "facebook.com" not in link and "usnews.com" not in link and "google.com" not in link and ".gov/" not in link \
                    and "mapquest.com" not in link and "wikipedia.org" not in link and "niche.com" not in link and "trulia.com" not in link and "zillow.com" not in link \
                    and "redfin.com" not in link and "linkedin.com" not in link and "justia" not in link and "twitter.com" not in link:
                break

        # insert into mongo
        try:
            col.insert_one(results)
        except Exception as e:
            print('\tCannot add search result into mongodb!')
            print(e)
            traceback.print_exc()

    except Exception as e:
        print('\tCannot search url!')
        print(e)
        traceback.print_exc()
        ecsv_out.writerow(row)

    # sleep(.5)  # Time in seconds, needed if using the free tier