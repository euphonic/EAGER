import csv
import requests
import pandas as pd
from pws import Bing
import FirmDB.settings
import pprint
from urllib.parse import urlparse

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

    pp = pprint.PrettyPrinter()
    pp.pprint(firms)
    
    return firms

if __name__ == "__main__":

    # Get the list of firms and domains
    firms = read_firms_csv(settings.INPUT_DATA)
    start_urls = [firm['url'] for firm in firms]
    allowed_domains = [firm['domain'] for firm in firms]

