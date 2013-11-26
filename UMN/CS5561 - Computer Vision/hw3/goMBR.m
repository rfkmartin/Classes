function out=goMBR(blob)

[a b]=size(blob.run);
xmin=240;ymin=320;xmax=0;ymax=0;

for i=1:b-1,
    if (blob.run(i).row>xmax)
        xmax=blob.run(i).row;
    end
    
    if (blob.run(i).row<xmin)
        xmin=blob.run(i).row;
    end
    
    if (blob.run(i).start<ymin)
        ymin=blob.run(i).start;
    end
    
    if (blob.run(i).fin>ymax)
        ymax=blob.run(i).fin;
    end
end

out.xmin=xmin;
out.ymin=ymin;
out.xmax=xmax;
out.ymax=ymax;
