use m101
db.profile.find({"ns":"school2.students"}).sort({"millis":-1}).limit(1).pretty()