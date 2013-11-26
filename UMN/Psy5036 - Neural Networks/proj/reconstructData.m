function out = reconstructData(avg,val,eigenV,neigen,index)

out=zeros(240*320*4,1)+reshape(avg,240*320*4,1);

for j=1:neigen,
   out=out+val(index,j)*eigenV(:,j);
end
