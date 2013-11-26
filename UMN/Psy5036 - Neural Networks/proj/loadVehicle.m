function out=loadVehicle(nvehicles, type)

%read in images
for n=1:nvehicles,
   [X,MAP]= tiffread(sprintf('%s%s%d%s','images/',type,n,'.tif'));
   vehicle(1:480,1+(n-1)*640:n*640)=resizeV(ind2gray(X,MAP));
end

out=vehicle;
