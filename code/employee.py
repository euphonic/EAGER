# sarora@air.org
# initially authored august 2018
# purpose: go through a list of firm names and via Google's custom search api
#   find employee size and LinkedIn company page, along with LinkedIn company name
# note: employee size is not disclosed on the company page (this would require scraping of linked in, or using the linked in api which isn't open)
#  instead use the number of individuals on LinkedIn as a proxy
# input: as csv file "firm name, url"
# output: as csv file "firm name,url,LinkedIn employees,LinkedIn url,LinkedIn matched name,jaro-winkler distance result"

import csv
import re
import pprint
from googleapiclient.discovery import build
import textdistance
import collections

f_in = open('/Users/sarora/dev/EAGER/data/test_li_urls.csv')
csv_in = csv.reader(f_in)

f_out = open('/Users/sarora/dev/EAGER/data/test_out_urls+emps4.csv', 'w')
csv_out = csv.writer(f_out)

service = build("customsearch", "v1",
                developerKey="AIzaSyCGSAZr9pYt_ALZBryuVwwpOjxCR4k8-TQ")

p = re.compile(r'\b\d+\b')

csv_out.writerow(["firm name", "url", "LinkedIn employees", "LinkedIn url", "LinkedIn matched name", "jaro-winkler distance result"])

for row in csv_in:
    firm = row[0]
    url = row[1]
    firm_clnd = re.sub('(\.|,| corporation| incorporated| llc| inc| international)', '', firm).rstrip()
    search_term = firm_clnd + ' "see all"'

    if len(firm_clnd) < 5:
        url_clnd = re.sub('(http(s)?://)|/', '', url).lstrip()
        search_term = search_term + ' ' + url_clnd

    print("Working on ", search_term)

    res = service.cse().list( # find
        q=search_term,
        cx='007721750960636651249:ad5w3ishg9q',
    ).execute()

    # pp = pprint.PrettyPrinter()
    # pp.pprint (res)

    li_dict = collections.defaultdict(dict)

    items = res["items"]
    rank = 1
    for i in range(len(items)): # go through
        formattedUrl = items[i].get("formattedUrl", None)
        if "/showcase/" in formattedUrl or "/in/" in formattedUrl or "/.../" in formattedUrl:
            # print ("\tContinuing on ", formattedUrl)
            continue
        # else:
        #     print("\tProcessing ", formattedUrl)

        snippet = items[i].get("snippet", None)
        title = items[i].get("title", None) # formatted "company name | LinkedIn"
        li_firm = title.split('|')[0].rstrip()

        li_dict[li_firm]["jaro"] = textdistance.hamming(firm_clnd, li_firm)
        snippet_clnd = re.sub("[,.]", "", snippet)
        emps = re.findall(p, snippet_clnd)
        if emps:
            li_dict[li_firm]["emps"] = emps[0]
        else:
            li_dict[li_firm]["emps"] = ''

        li_dict[li_firm]["formattedUrl"] = formattedUrl
        li_dict[li_firm]["rank"] = rank
        rank = rank + 1

    srtd_keys = sorted(li_dict, key=lambda x: (li_dict[x]['rank']))
    if not srtd_keys:
        csv_out.writerow([firm, url, "", "", "", ""])
    else:
        match_key = srtd_keys[0]
        csv_out.writerow([firm, url, li_dict[match_key]["emps"], li_dict[match_key]["formattedUrl"], match_key, li_dict[match_key]["jaro"] ])
