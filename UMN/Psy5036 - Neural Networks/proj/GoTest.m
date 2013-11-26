function out=GoTest(test)

% load eigenVehicle data
eigV=loadEigenV(13);

% load test image
testV=loadTest(test);

% load average vehicle
avgV=loadAvgV;

% get eigenVehicle projection of test image
vals = projectTest(testV,avgV,eigV,13);

% reconstruct test image

out=reshape(reconstructTest(avgV,vals,eigV,13),480,640);
