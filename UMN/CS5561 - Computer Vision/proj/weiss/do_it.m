function do_it(string,n0,n)

for i=1:5,
    im(:,:,i)=double(imread(sprintf('%s%03d.tif',string,n0+15*(i-1))));
end

[a,b]=size(im(:,:,1));

im=zeroB(im,2);
[dx,dy]=getAlbedo(im);
mxsize=max(a,b);
invK=invDel2(2*mxsize);
invKhat=fft2(invK);
imR=reconsEdge3(dx,dy,invKhat);
figure(2);show(imR);

for i=45:4:n,
    tic
    % get image and find lighting
    in1=double(imread(sprintf('%s%03d.tif',string,n0+(i-1))));
    in=zeroB(in1,2);
    dx1=conv2(in,[0 -1 1],'same');
    dy1=conv2(in,[0 -1 1]','same');
    out=reconsEdge3(dx1-dx,dy1-dy,invKhat);
    figure(1);show(in1);
    
    % threshold recovered image
    h=hist(reshape(out,1,a*b),linspace(-150,150,301));
    pk=max(h);
    start=find(h==pk);
    start=start(1);
    lthresh=start-1;
    temp=h(lthresh);
    while(temp>0.05*pk)
        lthresh=lthresh-1;
        temp=h(lthresh);
    end
    rthresh=start+1;
    temp=h(rthresh);
    while(temp>0.05*pk)
        rthresh=rthresh+1;
        temp=h(rthresh);
    end

    % binarize image
    %bin_im=(out<(lthresh-150))|(out>(rthresh-150));
    bin_im=out>(rthresh-150);
    %figure(1);imshow(bin_im);
    
    % erode once, dilate twice, find blobs less than 100
    diff=bwmorph(bin_im,'erode');
    diff=bwmorph(diff,'dilate');
    diff=bwmorph(diff,'dilate');
    blobs=myruns(diff,200);
    
    [c d]=size(blobs);
    for j=1:d,
        % draw centroid
        cg=goCentroid(blobs(j));
        %h=line([cg.cgy cg.cgy],[cg.cgx-5 cg.cgx+5]);
        %set(h,'Color',[1 0 0]);
        %h=line([cg.cgy-5 cg.cgy+5],[cg.cgx cg.cgx]);
        %set(h,'Color',[1 0 0]);
        
        % compute and draw principal components
        bl=goArray(blobs(j));
        bl(:,1)=bl(:,1)-cg.cgx;
        bl(:,2)=bl(:,2)-cg.cgy;
        covb=bl'*bl;
        [pc foo bar]=svd(covb);
        u=pc(:,1);v=pc(:,2);
        %h=line([cg.cgy cg.cgy+20*u(2)],[cg.cgx cg.cgx+20*u(1)]);
        %set(h,'Color',[1 0 0]);
        %h=line([cg.cgy cg.cgy+20*v(2)],[cg.cgx cg.cgx+20*v(1)]);
        %set(h,'Color',[1 0 0]);
        
        mbr=goPeri1(blobs(j),a,b,cg,u,v);
        drawMBR(mbr);
    end
        
    %figure(2);imshow(bin_im);
    i,toc
    pause;
end