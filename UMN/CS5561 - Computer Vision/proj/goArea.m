function out=goArea(blob)

[a b]=size(blob.run);
area=0;

for i=1:b-1,
    area=area+(blob.run(i).fin-blob.run(i).start+1);
end

out=area;