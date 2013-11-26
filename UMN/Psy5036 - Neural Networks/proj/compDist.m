function out=compDist(vals)

[m,n]=size(vals);
mvals=mean(vals);

for i=1:m,
  out(i)=norm(mvals-vals(i,:));
end
