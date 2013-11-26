function invKhat=doitrgb(string,n0,n)

% define filters
smooth=[1 2 1;2 4 2;1 2 1];

for i=1:19,
    temp=uint8(imread(sprintf('%s%02d.jpg',string,30+(i-1))));
    %figure(1);image(temp);pause;
    imr(:,:,i)=round(normal(filter2(smooth,temp(:,:,1)),0,255));
    img(:,:,i)=round(normal(filter2(smooth,temp(:,:,2)),0,255));
    imb(:,:,i)=round(normal(filter2(smooth,temp(:,:,3)),0,255));
end

i

[a,b]=size(imr(:,:,1));

imr=zeroB(imr,2);
img=zeroB(img,2);
imb=zeroB(imb,2);
[dxr,dyr]=getAlbedo(imr);
[dxg,dyg]=getAlbedo(img);
[dxb,dyb]=getAlbedo(imb);
mxsize=max(a,b);
invK=invDel2(2*mxsize);
invKhat=round(fft2(invK));
imRr=reconsEdge3(dxr,dyr,invKhat);
imRg=reconsEdge3(dxg,dyg,invKhat);
imRb=reconsEdge3(dxb,dyb,invKhat);
imR=uint8(zeros(a,b,3));
imR(:,:,1)=imRr;
imR(:,:,2)=imRg;
imR(:,:,3)=imRb;
imwrite(imR,'bg.jpg','jpg');
figure(3);imshow(imR);pause;

for i=11:8:n,
    tic
    % get image and find lighting
    temp=double(imread(sprintf('%s%03da.tif',string,n0+(i-1))));
    in1=round(normal(filter2(smooth,temp),0,255));
    in=zeroB(in1,2);
    dx1=conv2(in,[0 -1 1],'same');
    dy1=conv2(in,[0 -1 1]','same');
    out=reconsEdge3(dx1-dx,dy1-dy,invKhat);
    figure(1);show(in1);
    
    % threshold recovered image
    h=hist(reshape(out,1,a*b),linspace(-150,150,301));
    %bar(h);
    %saveas(gcf,'hist','bmp');
    %pause;
    pk=max(h);
    start=find(h==pk);
    start=start(1);
    lthresh=start-1;
    temp=h(lthresh);
    while(temp>0.075*pk)
        lthresh=lthresh-1;
        temp=h(lthresh);
    end
    rthresh=start+1;
    temp=h(rthresh);
    while(temp>0.075*pk)
        rthresh=rthresh+1;
        temp=h(rthresh);
    end

    % binarize image
    bin1=(out<(lthresh-150))|(out>(rthresh-150));
    %bin1=(out>(rthresh-150));
    %bin1=double(bwmorph(bwmorph(bin1,'erode'),'erode'));
    
    % use histogram of illuminated areas to find shadows
    illum_temp=bin1.*in1;
    %illum_temp1=filter2([-1 0 1;-2 0 2;-1 0 1],illum_temp,'same');
    %illum_temp2=filter2([-1 -2 -1;0 0 0;1 2 1],illum_temp,'same');
    %illum_temp3=(illum_temp1.*illum_temp1+illum_temp2.*illum_temp2).^(1/2);
    %illum_temp3=illum_temp3.*bin1;
    %figure(4);mesh(illum_temp3);pause;
    illum=illum_temp(:);
    h1=histc(illum(illum>0),linspace(0,255,256));
    % smooth histogram
    for i1=1:4,
        for j1=1:256,
            htemp(j1)=sum(h1(max(1,j1-3):min(255,j1+3)));
        end
        h1=htemp;
    end
    
    poscnt=0;
    mdir=0;
    i1=10;
    while (poscnt<2),
        m=h1(i1+2)-h1(i1-2);
        if ((mdir==0)&(m>0)),
            mdir=1;
            poscnt=poscnt+1;
        end
        if ((mdir==1)&(m<0)),
            mdir=0;
        end
        i1=i1+1;
    end
    
    bin2=in1>i1;
    bin_im=bin1&bin2;
    bin_im=double(bwmorph(bwmorph(bin_im,'erode'),'erode'));
    %figure(3);imshow(bin_im);pause;
    %bin_im=out>(rthresh-150);
    
    % erode once, dilate twice, find blobs w/area < 75
    %diff=bwmorph(bin_im,'erode');
    %diff=bwmorph(diff,'dilate');
    diff=bwmorph(bin_im,'dilate');
    %figure(1);imshow(bin_im);pause;
    blobs=myruns(diff,75);
    
    [c d]=size(blobs);
    reco=zeros(size(in1));
    for j=1:d,
        reco=recon(blobs(j).run,reco);
    end
    diff=double(bwmorph(bwmorph(reco,'dilate'),'dilate'));
    blobs=myruns(diff,175);
    [c d]=size(blobs);
    reco=zeros(size(in1));
    for j=1:d,
        reco=recon(blobs(j).run,reco);
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
        [pc foo fnord]=svd(covb);
        u=pc(:,1);v=pc(:,2);
        %h=line([cg.cgy cg.cgy+20*u(2)],[cg.cgx cg.cgx+20*u(1)]);
        %set(h,'Color',[1 0 0]);
        %h=line([cg.cgy cg.cgy+20*v(2)],[cg.cgx cg.cgx+20*v(1)]);
        %set(h,'Color',[1 0 0]);
        
        mbr=goPeri1(blobs(j),a,b,cg,u,v);
        drawMBR(mbr);
    end
    
    %temphist=in1.*reco;
    %tmask=temphist>0;
    %temphist1=temphist(:);
    %figure(3);show(temphist);
    %figure(4);bar(histc(temphist1(temphist1>0),linspace(0,255,256)));pause;
    %toc
    saveas(gcf,sprintf('./out/out%.02d',i+n0),'bmp');
    %pause;
    i
end
toc