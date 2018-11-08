import csv
import FirmDB.settings
import pprint
from urllib.parse import urlparse
import requests


def fix_urls (firms):
    s = requests.Session()
    for firm in firms:
        url = firm['url']
        http_url = "http://" + url
        resp = s.get(http_url)
        if resp.status_code == 200:
            firm['url'] = http_url
            continue
        http_www_url = "http://www." + url
        resp = s.get(http_www_url)
        if resp.status_code == 200:
            firm['url'] = http_www_url
            continue
        https_url = "https://" + url
        resp = s.get(https_url)
        if resp.status_code == 200:
            firm['url'] = https_url
            continue
        https_www_url = "https://www." + url
        resp = s.get(https_www_url)
        if resp.status_code == 200:
            firm['url'] = https_www_url
            continue

    return firms

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

            # If no URL is available, don't append the school
            if firm['url'] == '': continue
            # Parse the website domain from the full URL
            firm['domain'] = urlparse(firm['url']).netloc
            firms.append(firm)

    firms_fixed_urls = fix_urls (firms)
    pp = pprint.PrettyPrinter()
    pp.pprint(firms_fixed_urls)
    
    return firms_fixed_urls

if __name__ == "__main__":

    # Get the list of firms and domains
    firms = read_firms_csv(settings.INPUT_DATA)
    start_urls = [firm['url'] for firm in firms]
    allowed_domains = [firm['domain'] for firm in firms]

