function [dx,dy]=getAlbedo(bigIm1)

for i=1:size(bigIm1,3)
  dxs(:,:,i)=conv2(bigIm1(:,:,i),[0 -1 1],'same');
  dys(:,:,i)=conv2(bigIm1(:,:,i),[0 -1 1]','same');
end

dx=median(dxs,3);
dy=median(dys,3);


