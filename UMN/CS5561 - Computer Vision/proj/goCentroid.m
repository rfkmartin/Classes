function out=goCentroid(blob)

[a b]=size(blob.run);
xsum=0;
ysum=0;
count=0;

for i=1:b-1,
    trow=blob.run(i).row;
    tstart=blob.run(i).start;
    tfin=blob.run(i).fin;
    count=count+(tfin-tstart+1);
    xsum=xsum+trow*(tfin-tstart+1);
    ysum=ysum+(tfin-tstart+1)*(tstart+tfin)/2;
end

out.cgx=xsum/count;
out.cgy=ysum/count;