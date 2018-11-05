import pymongo
from pprint import pprint
import config

if __name__ == '__main__':
    client = pymongo.MongoClient(config.connection_string)
    db = client['EAGER']
    collection = db['firmPages']

    print(collection.find_one())
    serverStatusResult=db.command("serverStatus")
    pprint(serverStatusResult)

    print("Number of records: ", collection.find().count())

