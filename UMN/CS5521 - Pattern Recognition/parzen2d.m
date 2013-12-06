function out=parzen2d(in)

[a b]=size(in);

for j=1:301,
    for i=1:301,
        out(i,j)=0;
        for k=1:b,
            if (norm([(((i-1)/10)-15)-in(1,k) (((j-1)/10)-15)-in(2,k)])<3)
                out(i,j)=out(i,j)+(1/(3*3.14159))*(3-norm([(((i-1)/10)-15)-in(1,k) (((j-1)/10)-15)-in(2,k)]));
            end
        end
    end
end
