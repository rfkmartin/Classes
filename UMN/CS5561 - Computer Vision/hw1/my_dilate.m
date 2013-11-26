function out=my_dilate(A)

% MY_DILATE(A)
%
% convolves a 3x3 matrix of ones with
% image A.

dil=[1 1 1;1 1 1;1 1 1];
out=filter2(dil,A);