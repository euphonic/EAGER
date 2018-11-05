var duplicates = [];

db.bingResults.aggregate([
  { $group: { 
    _id: { name: "$queryContext.originalQuery"}, // can be grouped on multiple properties 
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
    doc.dups.shift();      // First element skipped for deleting
    doc.dups.forEach( function(dupId){ 
        duplicates.push(dupId);   // Getting all duplicate ids
        }
    )    
})

// If you want to Check all "_id" which you are deleting else print statement not needed
printjson(duplicates);     

// Remove all duplicates in one go    
db.bingResults.remove({_id:{$in:duplicates}}) 
