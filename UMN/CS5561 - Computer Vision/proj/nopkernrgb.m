function out=nopkernrgb(string)

% define filters
smooth=[1 2 1;2 4 2;1 2 1];

for i=1:5,
    temp=double(imread(sprintf('%s%03d.jpg',string,i+29)));
    im(:,:,1,i)=temp(:,:,1);
    im(:,:,2,i)=temp(:,:,2);
    im(:,:,3,i)=temp(:,:,3);
    %im(:,:,i)=round(normal(filter2(smooth,temp),0,255));
end

[a,b]=size(im(:,:,1,1));

for i=2:5,
    for j=1:2, % only need to do red and green
        imabs(:,:,j,i-1)=abs(im(:,:,j,i-1)-im(:,:,j,i));
    end
end

% finding sigma^2
immed=median(imabs,4);
sigma=immed/(0.68*sqrt(2));
sigmasq=sigma.*sigma;

% removing zeros for potential divide by zero errors
z=find(sigmasq==0);
sigmasq(z)=1e-10;

for xm=1:1,
% making frame for current image
% to accomodate false suppression
frame=zeros(a+2,b+2,3);
frame(2:a+1,2:b+1,:)=im(:,:,:,xm);
xm

Pr=zeros(a,b,1);
for i=1:5,
    Prt=ones(a,b,1);
    for x=2:2,
        for y=2:2,
            for j=1:2, % only need to do red and green
                temp1=frame(x:a+x-1,y:b+y-1,:);
                Prt=Prt.*(1./sqrt(2*pi*sigmasq(:,:,j))).*exp((-1/2)*...
                    (im(:,:,j,i)-temp1(:,:,j)).*(im(:,:,j,i)-temp1(:,:,j))./...
                    sigmasq(:,:,j));    
            end
        end
    end
Pr=Pr+Prt;
end
out=max(Pr,3);
imwrite(out<0.5,sprintf('out%0d.jpg',xm),'jpg');
end