function [mag,dir] = prewitt(in)

% [MAG,DIR] = PREWITT(IN)
%
% applies a 3x3 Prewitt edge operator to the
% input image in. Outputs the scaled magnitude
% image.

[in_hor,in_ver]=my_conv2p(in);

% absolute value is quicker than squares and square roots
mag=abs(in_hor)+abs(in_ver);
dir=atan2(in_hor,in_ver);

% normalize
mag=normal(mag,0,255);
dir=normal(dir,0,255);