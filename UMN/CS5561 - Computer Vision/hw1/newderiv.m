function [mag,dir] = newderiv(in)

% out = sobel(IN)
%
% applies a 3x3 Laplacian operator to the
% input image in. Outputs the scaled magnitude
% image.

deriv=[0 -1 0;-1 4 -1;0 -1 0];

hor=filter2(deriv,in);
ver=filter2(-deriv',in);

% absolute value is quicker than squares and square roots
mag=abs(hor)+abs(ver);
dir=atan2(ver,hor);

% normalize
mag=normal(mag,0,255);
dir=normal(dir,0,255);