function out=loadTest(test)

%read in images
[X,MAP]= tiffread(sprintf('images/test%d%s',test, '.tif'));
testV=ind2gray(X,MAP);

out=testV;
