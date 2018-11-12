import argparse
import logging
from time import time
from multiprocessing.pool import Pool
from pymongo import MongoClient, ASCENDING
from settings import MONGO_HOST, MONGO_PORT, MONGO_DATABASE, MONGO_COLLECTION, MAX_PAGE_SIZE, WORKERS,username,password,authSource,authMechanism

try:
    from settings import PAGE_SERVER_URL
    from tornado.httpclient import HTTPClient, HTTPRequest
    from urllib.parse import urlencode
    import json
except ImportError:
    from extractors import extract_all

    PAGE_SERVER_URL = None

logger = logging.getLogger("parser")
logger.setLevel(logging.INFO)
logger.propagate = False
fh = logging.FileHandler("parser.log", mode="w")
ch = logging.StreamHandler()
formatter = logging.Formatter("%(asctime)s - %(name)s - %(levelname)s - %(message)s")
fh.setFormatter(formatter)
ch.setFormatter(formatter)
logger.addHandler(fh)
logger.addHandler(ch)


def process_page_remotely(page_id, html, input_schools):
    post_fields = [("page_id", page_id), ("html", html)]
    for school in input_schools:
        post_fields.append(("input_schools", school))
    request = HTTPRequest(url=PAGE_SERVER_URL, method='POST', headers=None, body=urlencode(post_fields).encode())
    response = HTTPClient().fetch(request)
    features = json.loads(response.body)["features"]
    return features


def process_page(parameters):
    with MongoClient(MONGO_HOST, MONGO_PORT, username=username, password=password, authSource=authSource, authMechanism=authMechanism) as conn:
        coll = conn[MONGO_DATABASE][MONGO_COLLECTION]
        try:
            if PAGE_SERVER_URL:
                features = process_page_remotely(parameters["id"], parameters["html"], parameters["input_schools"])
            else:
                features = extract_all(parameters["html"], parameters["input_schools"])
            coll.update_one({"_id": parameters["id"]},
                            {"$set": {"parsed_features": features,
                                      "parser_status": "success"}})
            logger.info("Document {} from {} is processed {}".
                        format(parameters["page_number"], parameters["pages_count"],
                               "({} limit)".format(parameters["pages_limit"]) if parameters["pages_limit"] else ""))
        except Exception as e:
            coll.update_one({"_id": parameters["id"]}, {"$set": {"parser_status": "failed"}})
            logger.error("Document {} from {} is failed {}".
                         format(parameters["page_number"], parameters["pages_count"],
                                "({} limit)".format(parameters["pages_limit"]) if parameters["pages_limit"] else ""))
            logger.error(e)


def init_mongo_collection():
    start_time = time()
    logger.info("Collection initialization is started")
    with MongoClient(MONGO_HOST, MONGO_PORT, username=username, password=password, authSource=authSource, authMechanism=authMechanism) as conn:
        coll = conn[MONGO_DATABASE][MONGO_COLLECTION]
        logger.info("Status reset...")
        coll.update_many({"parser_status": {"$exists": True}},
                         {"$unset": {"parser_status": 1}})
        logger.info("Pages preselection...")
        coll.update_many({"html": {"$exists": True},
                          "body": {"$exists": True},
                          "schoolnames": {"$exists": True},
                          "$expr": {"$lt": [{"$strLenCP": {"$arrayElemAt": ["$html", 0]}}, MAX_PAGE_SIZE]}},
                         {"$set": {"parser_status": "not_processed"}})
        logger.info("Index build...")
        coll.create_index([("parser_status", ASCENDING)])
        logger.info("Reindexing...")
        coll.reindex()
    end_time = time()
    logger.info("Collection initialization is finished in {:.3f} minutes".format((end_time - start_time) / 60))


def process_mongo_collection(workers_number, pages_limit):
    start_time = time()
    logger.info("Parser is started")
    with MongoClient(MONGO_HOST, MONGO_PORT, username=username, password=password, authSource=authSource, authMechanism=authMechanism) as conn:
        coll = conn[MONGO_DATABASE][MONGO_COLLECTION]
        # pages = coll.find(pages{"parser_status": {"$in": ["not_processed", "failed"]}}).limit(pages_limit)
        pages = coll.find().limit(pages_limit)
        pages_count = pages.count()
        with Pool(workers_number) as executor:
            for _ in executor.imap_unordered(process_page,
                                             ({"id": page["_id"],
                                               "html": page["html"][0],
                                               # "input_schools": page["schoolnames"][0].split(";"),
                                               "input_schools": '',
                                               "page_number": i + 1,
                                               "pages_limit": pages_limit,
                                               "pages_count": pages_count} for i, page in enumerate(pages))):
                pass
    end_time = time()
    logger.info("Parser is finished in {:.3f} minutes".format((end_time - start_time) / 60))


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("-l", "--limit", type=int, default=0, help="specifies the amount of pages to process")
    parser.add_argument("--local", action="store_true", help="process pages locally")
    parser.add_argument("--resume", action="store_false", help="skip initialization and resume processing")
    parser.add_argument("-w", "--workers", type=int, default=WORKERS, help="number of parallel workers to run")
    args = parser.parse_args()
    if args.local:
        from extractors import extract_all

        PAGE_SERVER_URL = None
    # if args.resume:
        # init_mongo_collection()
    process_mongo_collection(args.workers, args.limit)

