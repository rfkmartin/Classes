function out = reconstructTest(avg,val,eigenV,neigen)

out=zeros(240*320*4,1)+reshape(avg,240*320*4,1);

for j=1:neigen,
   out=out+val(j)*eigenV(:,j);
end
