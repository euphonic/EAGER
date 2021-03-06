# aggregate by firm name
db.pages.aggregate(
	([ { $group: {"_id":"$firm_name" , "number":{$sum:1}} } ])
);

# exclude nulls
db.pages_COMBINED.aggregate(
	([ { $match : { "firm_name" : { "$exists": true, "$ne": null }} },
        { $group: {"_id":"$firm_name" , "number":{$sum:1}} } ])
).toArray().length;

# homepages only
db.pages_COMBINED.aggregate(
	([ { $match : {$and: [ { "firm_name" : { "$exists": true, "$ne": null }}, {"depth":0} ]} },
        { $group: {"_id":"$firm_name" , "number":{$sum:1}} } ])
).toArray().length
