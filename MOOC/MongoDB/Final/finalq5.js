use test
db.q5.insert({'a':1,'b':5,'c':10})
db.q5.insert({'a':2,'b':10,'c':100})
db.q5.insert({'a':3,'b':15,'c':1000})
db.q5.insert({'a':4,'b':20,'c':10000})
db.q5.insert({'a':5,'b':25,'c':100000})
db.q5.insert({'a':6,'b':30,'c':1000000})
db.q5.insert({'a':7,'b':35,'c':10000000})
db.q5.insert({'a':8,'b':40,'c':100000000})
db.q5.insert({'a':9,'b':45,'c':1000000000})
db.q5.insert({'a':10,'b':50,'c':10000000000})
db.q5.insert({'a':11,'b':55,'c':100000000000})
db.q5.ensureIndex({'a':1,'b':1})
db.q5.ensureIndex({'a':1,'c':1})
db.q5.ensureIndex({'c':1,})
db.q5.ensureIndex({'a':1,'b':1,'c':-1})
