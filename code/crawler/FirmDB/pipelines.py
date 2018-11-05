# -*- coding: utf-8 -*-

# Define your item pipelines here
#
# Don't forget to add your pipeline to the ITEM_PIPELINES setting
# See: http://doc.scrapy.org/en/latest/topics/item-pipeline.html

import pymongo
import FirmDB.settings
from scrapy.exceptions import DropItem
from FirmDB.config import connection_string
# from scrapy import log

class FirmDBPipeline(object):

    def __init__(self, mongo_uri, mongo_db):
        self.mongo_uri = mongo_uri
        self.mongo_db = mongo_db

    @classmethod
    def from_crawler(cls, crawler):
        return cls(
            mongo_uri = connection_string,
            mongo_db = FirmDB.settings.MONGODB_DB
        )

    def open_spider(self, spider):
        self.client = pymongo.MongoClient(self.mongo_uri)
        self.db = self.client[self.mongo_db]
        self.collection = self.db[FirmDB.settings.MONGODB_COLLECTION]

    def close_spider(self, spider):
        self.client.close()

    def process_item(self, item, spider):
        # print ("In process item")
        valid = True
        # print (item)
        for data in item:
            if not data:
                valid = False
                raise DropItem("Missing {0}!".format(data))
        if valid:
            print ("valid")
            self.collection.insert(dict(item))
            # log.msg("Page added to MongoDB database!", level=log.DEBUG, spider=spider)
        return item