function out = doStuff

m=2;
n=50;
noise=2;

data=genData(m,n,noise);

phi=genPhi;

%drawPhi(phi,5,m);

a=data*inv(phi);

drawAll(data,phi,5,m,a)

err=calcError(data,a,phi);
s=sprintf('error of %f',err);
title(s);
c=0;
s=sprintf('figure%03d',c);
saveas(gcf,s,'bmp');

while(c<1000),
    c=c+1;

    b=phi*data';

    C=a*phi*phi';

    sPrime=ones(size(a));
    j=find(a<0);
    sPrime(j)=-1;

    a=a+b'-C-0.14*sPrime;
    
    if (mod(c,10)==0),
        res=0.01*(data-a*phi)'*a;
        phi=phi+res;
        phi(1,:)=phi(1,:)/norm(phi(1,:));
        phi(2,:)=phi(2,:)/norm(phi(2,:));
    end
    err=calcError(data,a,phi);
    if (mod(c,5)==0),
        drawAll(data,phi,5,m,a);
        s=sprintf('error of %f',err);
        title(s);
        %pause;
        s=sprintf('figure%03d',c);
        saveas(gcf,s,'bmp');
    end
end



out=err;