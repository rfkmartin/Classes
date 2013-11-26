function out=BGud

i=0;

[X,MAP]=tiffread('windows/images/bg3.tif');
bg=ind2gray(X,MAP);
bg(120:140,150:170)=.5;
[a b]=size(bg);
mask=zeros(a,b);

for i=0:175/5,
   [X,MAP]=tiffread(sprintf('windows/images/frame%d%s',5*i,'.tif'));
   frame=ind2gray(X,MAP);
   figure(1);imshow(frame);
   [bg, new_mask]=bg_update(bg,frame);
   mask=or(mask,new_mask);
   figure(3);imshow(bg)
   figure(4);imshow(mask);
   i
   pause;
end
out=bg;