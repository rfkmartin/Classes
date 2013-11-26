function doAll(image)

blobs=myruns(image);
[a b]=size(blobs);

for i=1:b-1,
    d=sprintf('\nBlob %d', i);
    disp(d);
    d=sprintf('--------');
    disp(d);
    mbr=goMBR(blobs(i));
    d=sprintf('MBR:');
    disp(d);
    d=sprintf('  min x=%d\n  min y=%d\n  max x=%d\n  max y=%d',mbr.xmin,mbr.ymin,mbr.xmax,mbr.ymax);
    disp(d);
    cen=goCentroid(blobs(i));
    d=sprintf('Centroid: (x,y)=(%.2f,%.2f)',cen.cgx,cen.cgy);
    disp(d);
    a=goArea(blobs(i));
    d=sprintf('Area: %d',a);
    disp(d);
    [n1,cnt,pa]=goPeri(blobs(i));
    d=sprintf('Perimeter: %d',cnt);
    disp(d);
    if ((pa-a)>0)
        d=sprintf('Number of holes: %d', goHolecnt(n1));
        disp(d);
        d=sprintf('Area of holes: %d', pa-a);
        disp(d);
    end
    d=sprintf('Elongation: %.2f', cnt^2/pa);
    disp(d);
end