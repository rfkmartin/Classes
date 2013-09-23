function out=createCrescent(r1,d,c,c1)

numPts=d*pi*(r1^2);
count=0;
while(count <numPts),
    foo=rand(1,2)*4-2;
    if (foo(1)^2+foo(2)^2<=2 && (foo(1)-1.75*c1(1))^2 + (foo(2)-1.75*c1(2))^2 > 3),
        count=count+1;
        out(count,:)=foo+c;
    end,
end
