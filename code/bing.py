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
col = db["firm_url_search"]

pp = pprint.PrettyPrinter(indent=4)

f_in = open('/Users/sarora/dev/EAGER/data/orgs/companies-1.csv')
csv_in = csv.reader(f_in)

f_out = open('/Users/sarora/dev/EAGER/data/orgs/co_urls/company-1-urls_out.csv', 'w')
csv_out = csv.writer(f_out)

e_out = open('/Users/sarora/dev/EAGER/data/error_out.csv', 'w')
ecsv_out = csv.writer(e_out)

public_pat = re.compile("public*|trade*|trading|stock|NYSE|NASDAQ")
acquired_merged_pat = re.compile("merge*|acquisition|acquire|formerly|(last earnings release)|(spun off)")

csv_out.writerow(["firm name", "link", "acquired_merged", "public"])

subscription_key = "b955f2b5212a44589d84e7b1b7e9bb6b"
assert subscription_key
search_url = "https://api.cognitive.microsoft.com/bing/v7.0/search"
HITNUM = 8 # the number of search results to process for a given firm

for row in csv_in:
    search_term = row[0]
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
        acquired_merged = 0
        public = 0
        for i in range(HITNUM):
            hit = hits[i]
            link = hit['url']
            name = hit['name']
            snippet = hit['snippet']
            if "facebook.com" not in link and "usnews.com" not in link and "google.com" not in link and ".gov/" not in link \
                    and "mapquest.com" not in link and "wikipedia.org" not in link and "niche.com" not in link and "trulia.com" not in link and "zillow.com" not in link \
                    and "redfin.com" not in link and "linked.com" not in link and "justia" not in link and "twitter.com" not in link:
                break

            if public_pat.search(name) or public_pat.search(snippet):
                public = public + 1
            if acquired_merged_pat.search(name) or acquired_merged_pat.search(snippet):
                acquired_merged = acquired_merged + 1

        csv_out.writerow([search_term, link, acquired_merged, public])
        results['public'] = public
        results['acquired'] = acquired_merged
        try:
            db.collection.insert(results)
        except Exception as e:
            print('\tCannot add search result into mongodb!')
            print(e)
            traceback.print_exc()
    except Exception as e:
        print('\tCannot search url!')
        print(e)
        traceback.print_exc()
        csv_out.writerow([search_term, '', '', ''])
        ecsv_out.writerow(row)

    sleep(.5)  # Time in seconds.