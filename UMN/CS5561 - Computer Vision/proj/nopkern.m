function out=nopkern(string)

% define filters
smooth=[1 2 1;2 4 2;1 2 1];

for i=1:18,
    temp=double(imread(sprintf('%s%03d.tif',string,i+29)));
    im(:,:,i)=temp(:,:,1);
    %im(:,:,i)=round(normal(filter2(smooth,temp),0,255));
end

[a,b]=size(im(:,:,1));

for i=2:18,
    imabs(:,:,i-1)=abs(im(:,:,i-1)-im(:,:,i));
end

immed=median(imabs,3);

sigma=immed/(0.68*sqrt(2));

Pr=zeros(a,b);
for i=1:13,
    Pr=Pr+(1/9)*(1./sqrt(2*pi*sigma.*sigma)).*exp((-1/2)*...
        (im(:,:,i)-im(:,:,5)).*(im(:,:,i)-im(:,:,5))./(sigma.*sigma));
end

out=Pr;