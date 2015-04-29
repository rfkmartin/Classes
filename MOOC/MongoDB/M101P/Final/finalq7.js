use testm101p
db.albums.createIndex({"images":1});
db.images.createIndex({"_id":1});
cursor = db.images.find();
while ( cursor.count() ){
   var img = cursor.next();
   cursor2 = db.albums.find({"images":img._id});
   if (cursor2.count() ){
      var album = cursor2.next();
      //print("Image "+ img._id +" in album "+album._id);
   }
   else {
      //print("Image "+img._id +" in no album");
      db.images.remove({"_id":img._id});
   }
}
db.images.count();
db.images.find({"tags":"kittens"}).count();