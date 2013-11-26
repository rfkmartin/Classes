function [out1,out2,out3]=skeleton(name)

% SKELETON(IN)
%
% computes the medial axis
% of given image

% define filters
smooth=[1 2 1;2 4 2;1 2 1];
dilate=[1 1 1;1 1 1;1 1 1];

% load image
fname=sprintf('images/%s.bmp',name);
[X,MAP]=imread(fname);
in=(ind2gray(X,MAP));
figure(1);imshow(in);
in=round(in*255);

% smooth and normalize image
in=filter2(smooth,in);
in=round(normal(in,0,255));

% threshold image
thresh=myhisto(in);

% binarize and shrink/expand image
in=in>thresh;
%for i=1:2,
    in=filter2(dilate,in)>0;
%    in=zs_thin1(in);
%end

out1=in;
out=skel(in);

figure(2);
iptsetpref('ImshowAxesVisible','on');
imshow(not(in)|out);
out3=bwmorph(in,'skel',Inf);
figure(3);imshow(not(in)|out3);
out2=out;
