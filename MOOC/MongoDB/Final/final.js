use test
db.messages.aggregate([
   {$match :{$and:[{"headers.To": "jeff.skilling@enron.com"},{"headers.From": "andrew.fastow@enron.com"}]}},
   {$group :{_id: null, num_emails:{$sum:1}}}
])

db.messages.aggregate([
   {$unwind : "$headers.To"},
   {$group : {_id: {id: "$_id",   to:"$headers.To", from: "$headers.From"}, 'total':{"$sum":1}}},
   {$group :{_id: {From: "$_id.from", To:"$_id.to"}, 'total':{"$sum":1}}},
   {$sort :{total:-1}}
],{allowDiskUse: true})