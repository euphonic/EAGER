# -*- coding: utf-8 -*-
from scrapy.loader import ItemLoader
from scrapy.spiders import CrawlSpider, Rule
from scrapy.linkextractors import LinkExtractor
from FirmDB.items import Page
from FirmDB import settings
import logging
import pandas as pd
from FirmDB import read_urls
import pprint
import re
from selenium import webdriver
from selenium.webdriver.firefox.options import Options
import os, signal

def check_kill_process(pstring):
    for line in os.popen("ps ax | grep " + pstring + " | grep -v grep"):
        fields = line.split()
        pid = fields[0]
        os.kill(int(pid), signal.SIGKILL)

def url_to_filepath(url, prefix):
    url = url.split("//")[-1] # remove https:// prefix
    filepath = url.rstrip('.html').rstrip('.htm') + ".html"
    return prefix + '/' + filepath

class HTMLSpider(CrawlSpider):

    name = "HTML"
    firms = read_urls.read_firms_csv(settings.INPUT_DATA)

    start_urls = [firm['url'] for firm in firms]
    if settings.ALLOW_ALL_DOMAINS == False:
        allowed_domains = [firm['domain'] for firm in firms]

    # TODO: delete these lines?
    pages_to_scrape = 5
    # start_urls = [url['url'] for url in urls][:pages_to_scrape]
    # allowed_domains = [url['domain'] for url in urls][:pages_to_scrape]

    # To run on a single example
    # firms = [{'url': 'http://xxiicentury.com/', 'domain': 'xxiicentury.com/', 'firm_name': '22nd Century Limited'}]
    # start_urls = ['http://xxiicentury.com/']
    # allowed_domains = ['xxiicentury.com']

    print("Pages to scrape:", start_urls)
    df = pd.DataFrame(start_urls)
    df.to_csv('Output/start_urls.csv', index=False, header=False)
    # Starting with the start_urls, follow all pages recursively. Parse each page for links with parse_links()
    rules = (Rule(LinkExtractor(allow=()), callback='parse_links', follow=True),)

    def parse_links(self, response):
        options = Options()
        options.headless = True

        print("Crawling page:", response.url, "      ", end="")
        browser = webdriver.Firefox(options=options)
        browser.get(response.url)
        res = response.replace(body=browser.page_source)
        browser.close()
        browser.quit()
        # Create a Page item, which will be an item in the MongoDB database
        page = ItemLoader(item = Page(), response=res)

        page.add_value('url', response.url)
        domain = response.url.split("//")[-1].split('/')[0]
        page.add_value('domain', domain)

        depth = response.meta["depth"]
        referring_url = response.request.headers.get('Referer', None).decode('ASCII')

        if response.url in self.start_urls:
            depth = depth - 1
            check_kill_process('firefox')

        page.add_value('depth', depth)
        page.add_value('referring_url', referring_url)

        # Get HTML contents using xpaths
        page.add_xpath('html', '/html')
        page.add_xpath('head', '/html/head')
        page.add_xpath('title', '/html/head/title/text()')
        page.add_xpath('body', '/html/body')
        page.add_xpath('footer','//footer')

        full_text = response.xpath('//body//text()').extract()
        full_text_clnd = filter(lambda text: re.sub('\s',' ',text).strip(), full_text)
        page.add_value('full_text', full_text_clnd)

        # Get the relevant information corresponding to the url being crawled
        # url will be a dict of attributes corresponding to that row of the input file

        try:
            f = [firm for firm in self.firms if firm['domain'] in response.url][0]

            firm_name = f['firm_name']
            page.add_value('firm_name', firm_name)

        except:
            logging.error("Unable to find match for url: " + response.url)


        # TODO: add time the page was scraped

        yield page.load_item()
