function out=createCircle(r,d,c)

numPts=d*pi*(r^2);
count=0;
while(count <numPts),
    foo=rand(1,2)*2-1;
    if (foo(1)^2+foo(2)^2<=1),
        count=count+1;
        out(count,:)=foo*r+c;
    end,
end
