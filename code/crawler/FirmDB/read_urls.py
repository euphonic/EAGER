import csv
# import settings
import FirmDB.settings as settings
import pprint
from urllib.parse import urlparse
import requests
import traceback

def fix_urls (firms):
    firms_fixed_urls = []
    headers = {'User-Agent': 'Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10.10; rv:62.0) Gecko/20100101 Firefox/62.0'}
    timeout = 5

    for f in firms:
        firm = f
        print ("Checking url for " + firm['firm_name'])
        url = firm['url']
        
        try:
            http_url = "http://" + url
            print ("\tTrying: " + http_url)
            resp = requests.get(http_url, headers=headers, timeout=timeout, verify=False)
            print ("\tStatus code: " + str(resp.status_code))
            if resp.status_code >= 200 and resp.status_code < 400:
                firm['url'] = resp.url
                firm['domain'] = urlparse(firm['url']).netloc
                firms_fixed_urls.append(firm)
                continue
        except Exception as e: 
            print(e)
            # traceback.print_exc()

        try:
            http_www_url = "http://www." + url
            print ("\tTrying: " + http_www_url)
            resp = requests.get(http_www_url, headers=headers, timeout=timeout, verify=False)
            print ("\tStatus code: " + str(resp.status_code))
            if resp.status_code >= 200 and resp.status_code < 400:
                firm['url'] = resp.url
                firm['domain'] = urlparse(firm['url']).netloc
                firms_fixed_urls.append(firm)
                continue
        except Exception as e: 
            print(e)
            # traceback.print_exc()
       
        try:
            https_url = "https://" + url
            print ("\tTrying: " + https_url)
            resp = requests.get(https_url, headers=headers, timeout=timeout, verify=False)
            print ("\tStatus code: " + str(resp.status_code))
            if resp.status_code >= 200 and resp.status_code < 400:
                firm['url'] = resp.url
                firm['domain'] = urlparse(firm['url']).netloc
                firms_fixed_urls.append(firm)
                continue
        except Exception as e: 
            print(e)
            # traceback.print_exc()

        try:
            https_www_url = "https://www." + url
            print ("\tTrying: " + https_www_url)
            resp = requests.get(https_www_url, headers=headers, timeout=timeout, verify=False)
            print ("\tStatus code: " + str(resp.status_code))
            if resp.status_code >= 200 and resp.status_code < 400:
                firm['url'] = resp.url
                firm['domain'] = urlparse(firm['url']).netloc
                firms_fixed_urls.append(firm)
                continue
        except Exception as e: 
            print(e)
            # traceback.print_exc()

    return firms_fixed_urls 

def read_firms_csv (filename):
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

            # If no URL is available, don't append 
            if firm['url'] == '': continue
            # Parse the website domain from the full URL
            firms.append(firm)

    firms_fixed = []
    if settings.FIX_URLS:
        firms_fixed = fix_urls (firms)
    else:
        for f in firms:
            f['domain'] = urlparse(f['url']).netloc
        firms_fixed = firms

    firm_names_fixed = [firm_fixed['firm_name'] for firm_fixed in firms_fixed]
    firm_names = [firm['firm_name'] for firm in firms]

    pp = pprint.PrettyPrinter()
    pp.pprint(firms_fixed)
    
    print("Missing " + ', '.join(list(set(firm_names) - set(firm_names_fixed))) + " in the fixed urls list")
    return firms_fixed

if __name__ == "__main__":

    # Get the list of firms and domains
    firms = read_firms_csv(settings.INPUT_DATA)
    start_urls = [firm['url'] for firm in firms]
    allowed_domains = [firm['domain'] for firm in firms]

