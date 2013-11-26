function out=desub(i,ind)

% DESUB(I,IND)
%
% Takes the output of [i,ind]=find(...)
% for a 4D matrix and returns the
% original subscripts in a 4x1 array.

sz=[21 35 70];
for j=1:size(i),
   out(j,1)=i(j);
   [out(j,2) ind1]=ind2sub(sz,ind(j));
   [out(j,3) out(j,4)]=ind2sub([35 70],ind1);
end
