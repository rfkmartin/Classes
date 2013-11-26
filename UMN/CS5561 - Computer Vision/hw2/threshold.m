function out = threshold(in,thresh)

% out = threshold(IN,THRESH)
%
% performs thresholding on input image
% IN with specified value of THRESH.

out=(in>thresh)*255;