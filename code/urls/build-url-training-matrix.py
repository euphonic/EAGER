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
import getopt
from config import connection_string
from config import username
from config import password
from config import authSource
from config import authMechanism

options, remainder = getopt.getopt(sys.argv[1:], 'tv')

if (options is None or len(options) == 0):
    print("This script takes either a -t argument for test mode or a -v argument for validation.")
    sys.exit()

test_mode = None
for opt, arg in options:
    if opt in ('-t'):
        test_mode = True
    elif opt in ('-v'):
        test_mode = False

mdbc = pymongo.MongoClient(connection_string, username=username, password=password, authSource=authSource, authMechanism=authMechanism)
db = mdbc["EAGER"]
col = db["bingResults"]

pp = pprint.PrettyPrinter(indent=4)

f_in = open('/home/eager/EAGER/data/orgs/workshop/all_demo.csv')
csv_in = csv.reader(f_in)

f_out = open('/home/eager/EAGER/data/orgs/workshop/bing-final-test-matrix.csv', 'w')
csv_out = csv.writer(f_out)

if not test_mode:
    print(csv_out.writerow(["firm", "firm_length", "url", "name_clnd", "name_length", "hit_url", "hit_url_length", "rank", "matches", "public", "acquired_merged", "outcome"]))
else:
    print(csv_out.writerow(
        ["firm", "firm_length", "name_clnd", "name_length", "hit_url", "hit_url_length", "rank", "matches",
         "public", "acquired_merged"]))

public_pat = re.compile("public*|trade*|trading|stock|NYSE|NASDAQ", re.IGNORECASE)
acquired_merged_pat = re.compile("merge*|acquisition|acquire|formerly|(last earnings release)|(spun off)", re.IGNORECASE)

def ngrams(string):
    words = re.findall(r'\w+', string)
    return words

for row in csv_in:
    firm = row[0]
    firm_clnd = re.sub('(\.|,| corporation| incorporated| llc| inc| international| gmbh| ltd)', '', firm, flags=re.IGNORECASE).rstrip()
    if len(firm_clnd) <= 2:
        firm_clnd = firm

    firm_length = len(firm_clnd)
    firm_regex = '^' + firm_clnd + '$'
    firm_regex = re.sub('\(', '\\(', firm_regex)
    firm_regex = re.sub('\)', '\\)', firm_regex)

    url = None
    if not test_mode:
        url = row[1]
        if not url:
            continue

    query = { "queryContext.originalQuery": re.compile(firm_regex, re.IGNORECASE) }
    print (query)
    results = col.find(query)

    if results.count() > 1:
        print ("\tFound " + str(results.count() - 1) + " duplicate(s) in mongo of " + firm_clnd)
        continue
    elif results.count() == 0:
        print ("\tCannot find in mongo firm: " + firm_clnd)
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


        if hit_url.startswith('http'):
            hit_url = re.sub(r'https?:\/\/', '', hit_url)
        if hit_url.startswith('www.'):
            hit_url = re.sub(r'www.', '', hit_url)

        if not test_mode:
            if url.startswith('http'):
                url = re.sub(r'https?:\/\/', '', url)
            if url.startswith('www.'):
                url = re.sub(r'www.', '', url)
            if hit_url == url:
                outcome = 1

        # n-gram matching
        for fw in firm_words:
            if re.search(fw, name_clnd, re.IGNORECASE):
                matches = matches + 1

        out = None
        if test_mode:
            out = [firm, firm_length, name_clnd, name_length, hit_url, hit_url_length, rank, matches, public, acquired_merged]
        else:
            out = [firm, firm_length, url, name_clnd, name_length, hit_url, hit_url_length, rank, matches, public, acquired_merged, outcome]

        print(csv_out.writerow(out))