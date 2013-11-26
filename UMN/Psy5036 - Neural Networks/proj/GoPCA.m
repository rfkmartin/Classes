function [vals,vecs]=GoPCA(ncars,ntrucks,nothers)

% load vehicle data
cars=loadVehicle(ncars,'car');
trucks=loadVehicle(ntrucks,'truck');
others=loadVehicle(nothers,'other');

% compute averages
vehicles=[cars,trucks,others];
avgCar=compAvg(cars,ncars);
avgTruck=compAvg(trucks,ntrucks);
avgOther=compAvg(others,nothers);
avgV=(avgCar+avgTruck+avgOther)/3;

% save averages
imwrite(avgV,'images/avgV.tif','tif');
imwrite(avgOther,'images/avgOther.tif','tif');
imwrite(avgTruck,'images/avgTruck.tif','tif');
imwrite(avgCar,'images/avgCar.tif','tif');


% compute image differences
diffV=compDiff(vehicles,avgV,ncars+ntrucks+nothers);

% compute covariance matrix and top eigenVehicles
eigV=compEigV(diffV);
vecs=eigV;

% save eigenVehicles
for j=1:13,
   imwrite(reshape(eigV(:,j),480,640),sprintf('images/eigv%d%s',j,'.tif'),'tif');
end;

% get eigenVehicle projection of training set
vals = projectData(vehicles,avgV,eigV,13,ncars+ntrucks+nothers)

% reconstruct training set using eigenVehicles
for j=1:ncars,
   imwrite(reshape(reconstructData(avgV,vals,eigV,13,j),480,640),sprintf('images/eigcar%d%s',j','.tif'),'tif');
end

for j=1:ntrucks,
   imwrite(reshape(reconstructData(avgV,vals,eigV,13,j+ncars),480,640),sprintf('images/eigtruck%d%s',j','.tif'),'tif');
end

for j=1:nothers,
   imwrite(reshape(reconstructData(avgV,vals,eigV,13,j+ncars+ntrucks),480,640),sprintf('images/eigother%d%s',j','.tif'),'tif');
end

