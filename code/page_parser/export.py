import argparse
import csv
from time import time
from pymongo import MongoClient
from settings import MONGO_HOST, MONGO_PORT, MONGO_DATABASE, MONGO_COLLECTION, MIN_CONF_EXPORT


def export_to_csv(file_name, confidence_score):
    with open(file_name, 'w', newline='', encoding="utf-8") as f:
        writer = csv.writer(f)
        writer.writerow(["school_ids", "school_names", "school_name", "school_name_conf", "school_name_resolved", "url",
                         "name_conf_score_ub", "name", "context", "email", "phone", "cluster_score", "schema", "xml"])
        with MongoClient(MONGO_HOST, MONGO_PORT) as conn:
            coll = conn[MONGO_DATABASE][MONGO_COLLECTION]
            pages = coll.find({"parser_status": "success",
                               "parsed_features.resolution_score": {"$gte": confidence_score}})
            pages_cnt = pages.count()
            for i, page in enumerate(pages):
                print("Page {} from {} is processed".format(i + 1, pages_cnt))
                for name in page["parsed_features"]["resolved_context"]:
                    row = [page["school_ids"],
                           page["schoolnames"],
                           page["parsed_features"]["resolved_schools"]["resolved_school"],
                           page["parsed_features"]["resolved_schools"]["similarity_score"],
                           page["parsed_features"]["school_in_title"],
                           page["url"][0],
                           page["parsed_features"]["resolution_score"],
                           name["name"],
                           name["role"],
                           name["email"],
                           name["phone"],
                           name["cluster_score"],
                           name["schema"],
                           name["xml_context"]]
                    writer.writerow(row)


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("-f", "--file", type=str, default="results.csv", help="file name to export results")
    parser.add_argument("-c", "--conf", type=float, default=MIN_CONF_EXPORT, help="minimum resolution confidence score")
    args = parser.parse_args()
    start_time = time()
    print("Export is started")
    export_to_csv(args.file, args.conf)
    end_time = time()
    print("Export is finished in {:.3f} minutes".format((end_time - start_time) / 60))
