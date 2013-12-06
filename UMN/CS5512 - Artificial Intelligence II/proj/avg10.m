function out=avg10(scores)

[a b]=size(scores);
out=zeros(a-20+1,1);

for i=10:a-10,
    for j=1:20,
        out(i-10+1,1)=out(i-10+1,1)+scores(i-10+j,1);
    end
    out(i-10+1,1)=out(i-10+1,1)/20;
end