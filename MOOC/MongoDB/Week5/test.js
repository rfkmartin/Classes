use test
db.zips.aggregate([
    {$match:
       {$or: [{state:"NY"},{state:"CA"}]}
    },
    {$group:
     {
	 _id: {city: "$city",state:"$state"},
	 population: {$sum:"$pop"}
     }
    },
    { $match:
       {population:{$gt:25000}}
    },
    { $group :
       { _id: null, avgCityPop : { $avg : "$population" } } }
])

use blog
db.posts.aggregate([
   {$unwind : "$comments"},
   {$group :{_id: "$comments.author", num_comments:{$sum:1}}},
   {$sort: { num_comments:-1 } }
])

use test
db.grades.aggregate([
    {$unwind:"$scores"},
    {$match:{$or:[{"scores.type":"homework"},{"scores.type":"exam"}]}},
    {'$group':{_id:{class_id:"$class_id", student_id:"$student_id"}, 'average':{"$avg":"$scores.score"}}},
    {'$group':{_id:"$_id.class_id", 'average':{"$avg":"$average"}}},
    {$sort: { "average" : -1}}
])

db.zips.aggregate([
    {$project: { city:1, pop: 1, first_char: {$substr : ["$city",0,1]}}},
    {$match: {first_char:{$lt:"A"}}},
    {$group: {_id: null, totalSum: {$sum: "$pop"}}}
])