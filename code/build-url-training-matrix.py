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

pp = pprint.PrettyPrinter(indent=4)

f_in = open('/Users/sarora/dev/EAGER/data/training/urls/firm-urls-v5.csv')
csv_in = csv.reader(f_in)

f_out = open('/Users/sarora/dev/EAGER/data/training/urls/bing-firm-url-train-v5.csv', 'w')
csv_out = csv.writer(f_out)

public_pat = re.compile("public*|trade*|trading|stock|NYSE|NASDAQ", re.IGNORECASE)
acquired_merged_pat = re.compile("merge*|acquisition|acquire|formerly|(last earnings release)|(spun off)", re.IGNORECASE)

def ngrams(string):
    words = re.findall(r'\w+', string)
    return words

for row in csv_in:
    firm = row[0]
    firm_clnd = re.sub('(\.|,| corporation| incorporated| llc| inc| international)', '', firm).rstrip()
    firm_length = len(firm_clnd)
    firm_regex = '^' + firm_clnd
    url = row[1]
    if not url:
        continue

    query = { "queryContext.originalQuery": re.compile(firm_regex, re.IGNORECASE) }
    print (query)
    results = col.find(query)

    if results.count() != 1:
        continue

    print(results.count())

    hits = results.next()['webPages']['value']
    acquired_merged = 0
    public = 0

    rank = 0
    firm_words = ngrams(firm_clnd)

    for hit in hits:
        url = hit['url']
        url_length = len(url)
        outcome = None
        rank = rank + 1
        matches = 0

        name_clnd = hit['name'].encode('ascii', 'ignore').decode()
        name_length = len(name_clnd)

        if "facebook.com" in url or "usnews.com" in url or "google.com" in url or ".gov/" in url \
                or "mapquest.com" in url or "wikipedia.org" in url or "niche.com" in url or "trulia.com" in url or "zillow.com" in url \
                or "redfin.com" in url or "linkedin.com" in url or "justia" in url or "twitter.com" in url:
            continue

        if public_pat.search(hit['name']) or public_pat.search(hit['snippet']):
            public = public + 1
        if acquired_merged_pat.search(hit['name']) or acquired_merged_pat.search(hit['snippet']):
            acquired_merged = acquired_merged + 1

        if hit['url'] == url:
            outcome = 1
        else:
            outcome = 0

        # n-gram matching
        for fw in firm_words:
            if re.search(fw, name_clnd, re.IGNORECASE):
                matches = matches + 1

        print(csv_out.writerow([firm, firm_length, name_clnd, name_length, url, url_length, rank, matches, public, acquired_merged, outcome]))