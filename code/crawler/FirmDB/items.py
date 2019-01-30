# -*- coding: utf-8 -*-

# Define here the models for your scraped items
#
# See documentation in:
# http://doc.scrapy.org/en/latest/topics/items.html

import scrapy

class Page(scrapy.Item):

    # URL information
    url = scrapy.Field()
    domain = scrapy.Field()
    path = scrapy.Field()
    orig_url = scrapy.Field()

    # HTML information
    html = scrapy.Field()
    head = scrapy.Field()
    title = scrapy.Field()
    body = scrapy.Field()
    footer = scrapy.Field()

    # FirmDB custom fields
    firm_name = scrapy.Field()
    full_text = scrapy.Field()
    is_about = scrapy.Field()
    descriptor = scrapy.Field()
    total_about_pages = scrapy.Field()
    depth = scrapy.Field()
    referring_url = scrapy.Field()


