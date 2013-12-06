function out=parzen(in)

[a b]=size(in);

for i=1:301,
    out(2,i)=((i-1)/10)-15;
    out(1,i)=0;
    for j=1:b,
        if (abs((((i-1)/10)-15)-in(j))<4)
            out(1,i)=out(1,i)+0.25*(4-abs((((i-1)/10)-15)-in(j)))/4;
        end
    end
end

out(1,:)=out(1,:)/b;