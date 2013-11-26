function out=dpp(x,y,c,n)

[a b]=size(x);

for i=1:b,
    v1=[x(mod(i+b,b)+1)-x(mod(i+b-n,b)+1) y(mod(i+b,b)+1)-y(mod(i+b-n,b)+1)];
    v2=[x(mod(i+b+n,b)+1)-x(mod(i+b,b)+1) y(mod(i+b+n,b)+1)-y(mod(i+b,b)+1)];
    test=dot(v1,v2)/(norm(v1)*norm(v2));
    if (test>1)
        test=1;
    end
    out(i)=sign(c(i))*acos(test);
end