
function out = resizeV(vehicle)
% dummy function
% was supposed to resize image for computational considerations

[m,n]=size(vehicle);

for i=1:m/2,
   for j=1:n/2,
      newV(i,j)=vehicle(i*2,j*2);
   end
end

out = vehicle;