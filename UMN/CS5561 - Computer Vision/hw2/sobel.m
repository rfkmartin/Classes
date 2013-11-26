function [mag,dir] = sobel(in)

% out = sobel(IN)
%
% applies a 3x3 Sobel edge operator to the
% input image in. Outputs the scaled magnitude
% image.

%[hor,ver]=my_conv2s(in);
sob=[-1 0 1;-2 0 2;-1 0 1];
hor=filter2(sob,in);
ver=filter2(-sob',in);


% absolute value is quicker than squares and square roots
mag=abs(hor)+abs(ver);
dir=atan2(ver,hor)+pi;

% normalize
%mag=normal(mag,0,255);
%dir=normal(dir,0,255);