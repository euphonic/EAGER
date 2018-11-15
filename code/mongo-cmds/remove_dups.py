# Combine all collections in FirmDB
# Sanjay K Arora
# November 2018

# Input: A single target collection with duplicates (based on url)
# Output: The same collection with duplicates removed
# Ensure you have a backup if needed to ensure no unintended data loss!

import pprint
import sys
import pprint
import pymongo
import re
from FirmDB.config import connection_string
from FirmDB.config import username
from FirmDB.config import password
from FirmDB.config import authSource
from FirmDB.config import authMechanism

MONGODB_DB = "FirmDB"
TARGET_COLLECTION = "pages_COMBINED"

client = pymongo.MongoClient(connection_string, username=username, password=password, authSource=authSource,
                             authMechanism=authMechanism)
db = client[MONGODB_DB]
regex = re.compile('test|' + TARGET_COLLECTION)

def dedup():
    target_col = db[TARGET_COLLECTION]
    pipeline = [ { "$group": { "_id": { "name": "$url"}, "dups": { "$addToSet": "$_id" }, "count": { "$sum": 1 } }},
                 { "$match": { "count": { "$gt": 1 } }} ]
    grouped_by_url = target_col.aggregate(pipeline)
    print ('Found ' + str(len(grouped_by_url)) + ' documents with duplicate urls')
    # pp = pprint.PrettyPrinter()
    # pp.pprint(grouped_by_url)

# run main
dedup ()
