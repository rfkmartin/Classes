function out=smooth(in)

[a b]=size(in);

for i=1:b,
    out(i)=in(i)+in(mod(b+i-2,b)+1)+in(mod(i,b)+1);
end