function im=reconsEdge3(dx,dy,invKhat)
% given dx dy reconstruct image
% here we do the convolutions using FFT2

im=zeros(size(dx));
[sx,sy]=size(dx);
mxsize=max(sx,sy);

imX=conv2(dx,fliplr([0 -1 1]),'same');
imY=conv2(dy,flipud([0 -1 1]'),'same');

imS=imX+imY;

imShat=fft2(imS,2*mxsize,2*mxsize);
im=real(ifft2(imShat.*invKhat));
im=im(mxsize+1:mxsize+sx,mxsize+1:mxsize+sy);