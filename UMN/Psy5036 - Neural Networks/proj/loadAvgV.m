function out=loadAvgV

%read in image
[X,MAP]= tiffread(sprintf('images/avgV.tif'));
avgV=ind2gray(X,MAP);

out=avgV;
