function out=loadEigenV(neigV)

%read in images
for n=1:neigV,
   [X,MAP]= tiffread(sprintf('images/eigv%d%s', n,'.tif'));
   eigV(:,n)=reshape(ind2gray(X,MAP),480*640,1);
end

out=eigV;
