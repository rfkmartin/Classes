function out=goArray(blob)

[a b]=size(blob.run);
cnt=1;

for i=1:b-1,
    len=blob.run(i).fin-blob.run(i).start+1;
    out(cnt:cnt+len-1,2)=linspace(blob.run(i).start,...
            blob.run(i).fin,...
            len)';
    out(cnt:cnt+len-1,1)=linspace(blob.run(i).row,...
            blob.run(i).row,...
            len)';
    cnt=cnt+len;
end