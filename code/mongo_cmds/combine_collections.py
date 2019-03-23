# Combine all collections in FirmDB
# Sanjay K Arora
# November 2018

# Input: All collections in the DB without 'test' in their names
# Output: A pages_ALL collection
# Ensure you have enough disk space before running this command!
# Ensure you are working on the right collections! You may want to comment out the insert method to see what will be 
# changed by looking at collection names only 

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
TARGET_COLLECTION = "pages_ABOUT2"

client = pymongo.MongoClient(connection_string, username=username, password=password, authSource=authSource,
                             authMechanism=authMechanism)
db = client[MONGODB_DB]
regex = re.compile('pages_a\dm?')

def insert_col (name):
    source_col = db[name]
    target_col = db[TARGET_COLLECTION]
    docs = list(source_col.find())
    print ('Working on ' + name + ' with ' + str(len(docs)) + ' documents')
    results = target_col.insert_many(docs)
    # pp = pprint.PrettyPrinter()
    # pp.pprint(results)

def find_cols ():
    all_col_names = db.list_collection_names()
    col_names = [x for x in all_col_names if regex.search(x)]
    return col_names

# run main
all_cols = find_cols ()
print ('Going to work on ' + str(len(all_cols)) + ' collections:')
print ('\t' + '\n\t'.join(all_cols))
for col_name in all_cols:
     insert_col (col_name)
