import pymongo
from pprint import pprint
import config

if __name__ == '__main__':
    client = pymongo.MongoClient(config.connection_string)
    db = client['EAGER']
    collection = db['firmPages']

    collection.remove()
    print(collection.count())

    print("Number of records: ", collection.find().count())