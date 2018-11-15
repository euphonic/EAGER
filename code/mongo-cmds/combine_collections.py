# Combine all collections in FirmDB
# Sanjay K Arora
# November 2018

# Input: All collections in the DB without 'test' in their names
# Output: A pages_ALL collection
# Ensure you have enough disk space before running this command!

import csv
import pprint
import sys
import pprint
import pymongo
from urllib.parse import urlparse
from FirmDB.config import connection_string
from FirmDB.config import username
from FirmDB.config import password
from FirmDB.config import authSource
from FirmDB.config import authMechanism

MONGODB_DB = "FirmDB"
SOURCE_COLLECTION = "pages10_test"
TARGET_COLLECTION = "pages_ALL"

def insert_into ():
    client = pymongo.MongoClient(connection_string, username=username, password=password, authSource=authSource, authMechanism=authMechanism)
    db = client[MONGODB_DB]
    source_col = db[SOURCE_COLLECTION]
    target_col = db[TARGET_COLLECTION]
    docs = list(source_col.find())
    results = target_col.insertMany(docs)
    pp = pprint.PrettyPrinter()
    pp.pprint(list(results))

# run main
insert_into ()
