use testm101p
db.enron.find({$and:[{"headers.From": "andrew.fastow@enron.com"},{"headers.To": "john.lavorato@enron.com"}]}).pretty()
db.enron.aggregate([
   {$match :{$and:[{"headers.From": "andrew.fastow@enron.com"},{"headers.To": "john.lavorato@enron.com"}]}},
   {$group :{_id: null, num_emails:{$sum:1}}}
])
db.enron.aggregate([
   {$match :{$and:[{"headers.From": "andrew.fastow@enron.com"},{"headers.To": "jeffrey.skilling@enron.com"}]}},
   {$group :{_id: null, num_emails:{$sum:1}}}
])

db.enron.aggregate([
   {$unwind : "$headers.To"},
   {$group : {_id: {id: "$_id",   to:"$headers.To", from: "$headers.From"}, 'total':{"$sum":1}}},
   {$group :{_id: {From: "$_id.from", To:"$_id.to"}, 'total':{"$sum":1}}},
   {$sort :{total:-1}}
],{allowDiskUse: true})