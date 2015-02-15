cursor = db.images.find()
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
db.images.find({"tags":"sunrises"}).count();