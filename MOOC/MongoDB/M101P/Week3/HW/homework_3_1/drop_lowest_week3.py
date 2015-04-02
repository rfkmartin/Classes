import pymongo
import sys

connection = pymongo.MongoClient("mongodb://localhost")
db = connection.school
students =db.students

def remove_lowest():
  num_students = students.find().count()
  print num_students
  for i in range(0,num_students):
    doc = students.find_one({'_id':i})
    lowHW = 101
    for score in doc['scores']:
      if score['type'] == 'homework':
        if score['score'] < lowHW:
          lowHW = score['score']
    students.update({'_id':i},{ "$pull": { 'scores': { 'score':lowHW,'type': 'homework' } } } )

remove_lowest()