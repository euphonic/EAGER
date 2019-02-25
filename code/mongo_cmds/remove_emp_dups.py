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

MONGODB_DB = "EAGER"
TARGET_COLLECTION = "employeeResults"

connection_string = 'mongodb://localhost'

client = pymongo.MongoClient(connection_string)
db = client[MONGODB_DB]
target_col = db[TARGET_COLLECTION]
pp = pprint.PrettyPrinter()

def dedup():
    pipeline = [ { "$group": { "_id": { "query": "$queries.request.title"}, "dups": { "$addToSet": "$_id" }, "count": { "$sum": 1 } }},
                 { "$match": { "count": { "$gt": 1 } }} ]
    grouped_by_url = list(target_col.aggregate(pipeline))
    print ('Found ' + str(len(grouped_by_url)) + ' duplicate urls')
    # pp.pprint (grouped_by_url)
    
    to_delete_ids = []

    for doc in grouped_by_url:
        dups = doc['dups']
        print ('\tPopping: ' + str(dups.pop(0)))
        to_delete_ids.append(dups)

    flattened = [item for sublist in to_delete_ids for item in sublist] 
    # pp.pprint(flattened)
    return flattened

def batch_delete (ids):
    result = target_col.remove({'_id': {'$in': ids}})
    pp.pprint (result)

# run main
to_delete_ids = dedup ()
batch_delete (to_delete_ids)
