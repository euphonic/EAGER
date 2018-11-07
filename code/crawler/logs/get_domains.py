import re
import pprint
from urllib.parse import urlparse

def get_domains (filename):
    """
    Parse CSV files that contain:
    firm, url
    and return a list of dictionaries representing the firms

    :param filename:
    :return:
    """
    urls = []
    domains = {}
    
    with open(filename) as log_file:
        for line in log_file:
            urls = re.findall('https?://(?:[-\w.]|(?:%[\da-fA-F]{2}))+', line)
            for url in urls:
                domains[urlparse(url).netloc] = 1

    pp = pprint.PrettyPrinter()
    pp.pprint(domains)

if __name__ == "__main__":
    firms = get_domains("1.log")
