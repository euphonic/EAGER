# aggregate by firm name
db.pages.aggregate(
	([ { $group: {"_id":"$firm_name" , "number":{$sum:1}} } ])
);
