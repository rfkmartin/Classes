function bdraw(blobs)

[a b]=size(blobs);

for i=1:b-1,
   figure(i); temp=zeros(240,320);
   [c d]=size(blobs(i).run);
   for j=1:d-1,
      temp(blobs(i).run(j).row,blobs(i).run(j).start:blobs(i).run(j).fin)=1;
   end
   d=sprintf('Blob %d, reg4.jpg',i);
   iptsetpref('ImshowAxesVisible','on');
   imshow(not(temp)),title(d);
   mbr=goMBR(blobs(i));
   drawMBR(mbr);
end