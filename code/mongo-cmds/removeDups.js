// find duplicate urls and delete
// this script may not work if there are apostrophees and/or quotation marks in the urls
// use db.pages_COMBINED.find({url: /\x22/}); and db.pages_COMBINED.find({url: /\x27/}); to check

use FirmDB

var duplicates = [];

db.pages_COMBINED.aggregate([
  { $group: { 
    _id: { name: "$url"}, // can be grouped on multiple properties 
    dups: { "$addToSet": "$_id" }, 
    count: { "$sum": 1 } 
  }}, 
  { $match: { 
    count: { "$gt": 1 }    // Duplicates considered as count greater than one
  }}
],
{allowDiskUse: true}       // For faster processing if set is larger
)               // You can display result until this and check duplicates 
.forEach(function(doc) {
    printjson(doc);
    doc.dups.shift();      // First element skipped for deleting
    doc.dups.forEach( function(dupId){ 
        duplicates.push(dupId);   // Getting all duplicate ids
        }
    )    
})

// If you want to Check all "_id" which you are deleting else print statement not needed
printjson(duplicates);     

// Remove all duplicates in one go    
// db.pages_COMBINED.remove({_id:{$in:duplicates}})
