function out=recons(in,edges)

[a b]=size(in);
temp=zeros(a,b);
[m n]=size(edges);

for i=1:n,
   for j=1:edges(i).l-1,
      temp(edges(i).x(j),edges(i).y(j))=1;
   end
end
out=temp;