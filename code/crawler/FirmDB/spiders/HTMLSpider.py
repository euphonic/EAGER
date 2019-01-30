# -*- coding: utf-8 -*-
from scrapy.loader import ItemLoader
from scrapy.spiders import CrawlSpider, Rule, Spider
from scrapy.linkextractors import LinkExtractor
import scrapy
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
    for line in os.popen("kill -9 -$(ps -eo comm,pid,etimes | awk '/^" + pstring + "/ {if ($3 > 300) { print $2}}')"):
        fields = line.split()
        pid = fields[0]
        os.kill(int(pid), signal.SIGKILL)

def url_to_filepath(url, prefix):
    url = url.split("//")[-1] # remove https:// prefix
    filepath = url.rstrip('.html').rstrip('.htm') + ".html"
    return prefix + '/' + filepath

class HTMLSpider(Spider):

    name = "HTML"

    def __init__(self):
        self.firms = read_urls.read_firms_csv(settings.INPUT_DATA)
        if settings.ALLOW_ALL_DOMAINS == False:
            self.allowed_domains = [firm['domain'] for firm in self.firms]

    def start_requests(self):
        for index, firm in enumerate(self.firms):
            url = firm['url']
            yield scrapy.Request(url, meta={'firm':firm})

        # Starting with the start_urls, follow all pages recursively. Parse each page for links with parse_links()
        # rules = (Rule(LinkExtractor(allow=()), callback='parse_links', follow=True),)

    # start_urls = [firm['url'] for firm in firms]

    def parse(self, response):
        firm_meta = response.meta['firm']
        pp = pprint.PrettyPrinter()
        pp.pprint(firm_meta)

        options = Options()
        options.headless = True

        print("Crawling page:", response.url, "      ", end="")
        browser = webdriver.Firefox(options=options) 
        browser.get(response.url)
        res = response.replace(body=(browser.page_source).encode('utf-8'))
        browser.close()
        browser.quit()


        # Create a Page item, which will be an item in the MongoDB database
        page = ItemLoader(item = Page(), response=res)

        page.add_value('url', response.url)
        page.add_value('firm_name', firm_meta['firm_name'])
        page.add_value('domain', firm_meta['domain'])
        page.add_value('orig_url', firm_meta['url'])
        # domain = response.url.split("//")[-1].split('/')[0]
        
        if settings.ABOUT_MODE:
            page.add_value('is_about', firm_meta['is_about'])
            page.add_value('descriptor', firm_meta['descriptor'])
            page.add_value('total_about_pages', firm_meta['total_about_pages'])
        
        depth = response.meta["depth"]
        referring_url = response.request.headers.get('Referer', None)
        try:
            referring_url = referring_url.decode('ASCII')
        except:
            pass # don't kill parsing for the current instance if there is no referring_url
        
        # if response.url in self.start_urls:
            # depth = depth - 1
        
        check_kill_process('firefox') # needed because selenium doesn't always terminate browsers correctly
        
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
        
        
        # TODO: add time the page was scraped
        
        yield page.load_item()
