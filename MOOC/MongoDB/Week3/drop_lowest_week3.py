import pymongo
import sys

connection = pymongo.Connection("mongodb://localhost",safe=True)
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
    #if lowHW == 101:
    #  print "FRIG!"
    #print "low homework score for", doc['name'], ": ", lowHW
    #for score in (doc.scores):
    #  print score['type'], " ", score['score']
 #  cursor = grades.find({'type':'homework'}).sort([('student_id',pymongo.ASCENDING),('score',pymongo.ASCENDING)])

 # student_id = -1
 # for entry in cursor:
 #   print entry
 #   if (entry['student_id'] != student_id):
 #     remove_score(entry['_id'])
 # student_id = entry['student_id']

remove_lowest()