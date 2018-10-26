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

print(csv_out.writerow(
    ["firm", "firm_length", "url", "name_clnd", "name_length", "hit_url", "hit_url_length", "rank", "matches", "public", "acquired_merged", "outcome"]))

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

    print("\tNumber of results: " + str(results.count()))

    hits = results.next()['webPages']['value']
    acquired_merged = 0
    public = 0

    rank = 0
    firm_words = ngrams(firm_clnd)

    for hit in hits:
        hit_url = hit['url']
        hit_url_length = len(hit_url)
        outcome = 0
        rank = rank + 1
        matches = 0

        name_clnd = hit['name'].encode('ascii', 'ignore').decode()
        name_length = len(name_clnd)

        if "facebook.com" in hit_url or "usnews.com" in hit_url or "google.com" in hit_url or ".gov/" in hit_url or "youtube.com" in hit_url \
                or "mapquest.com" in hit_url or "wikipedia.org" in hit_url or "niche.com" in hit_url or "trulia.com" in hit_url or "zillow.com" in hit_url \
                or "redfin.com" in hit_url or "linkedin.com" in hit_url or "justia" in hit_url or "twitter.com" in hit_url:
            continue

        if public_pat.search(hit['name']) or public_pat.search(hit['snippet']):
            public = public + 1
        if acquired_merged_pat.search(hit['name']) or acquired_merged_pat.search(hit['snippet']):
            acquired_merged = acquired_merged + 1

        if hit_url == url:
            outcome = 1

        # n-gram matching
        for fw in firm_words:
            if re.search(fw, name_clnd, re.IGNORECASE):
                matches = matches + 1

        print(csv_out.writerow([firm, firm_length, url, name_clnd, name_length, hit_url, hit_url_length, rank, matches, public, acquired_merged, outcome]))