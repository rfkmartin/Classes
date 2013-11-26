function [out,out1]=lcode(chain)

[a b]=size(chain);

for i=2:b-1,
    out(i)=chain(i+1)-chain(i-1);
    if (out(i)==7)
        out(i)=-1;
    elseif (out(i)==6)
        out(i)=-2;
    elseif (out(i)==5)
        out(i)=-3;
    elseif (out(i)==-5)
        out(i)=3;
    elseif (out(i)==-6)
        out(i)=2;
    elseif (out(i)==-7)
        out(i)=1;
    end
    if (((out(i)>-4)&(out(i)<0))|(out(i)==6))
        out1(i)=-1;
    else
        out1(i)=1;
    end
end
out(1)=chain(2)-chain(b);

if (out(1)==7)
    out(1)=-1;
elseif (out(1)==6)
    out(1)==-2;
elseif (out(1)==5)
    out(1)==-1;
elseif (out(1)==-5)
    out(1)=3;
elseif (out(1)==-6)
    out(1)=2;
elseif (out(1)==-7)
    out(1)=1;
end
if (((out(1)>-4)&(out(1)<0))|(out(1)==6))
    out1(1)=-1;
else
    out1(1)=1;
end

out(b)=chain(1)-chain(b-1);

if (out(b)==7)
    out(b)=-1;
elseif (out(b)==6)
    out(b)==-2;
elseif (out(b)==5)
    out(b)==-1;
elseif (out(b)==-5)
    out(b)=3;
elseif (out(b)==-6)
    out(b)=2;
elseif (out(b)==-7)
    out(b)=1;
end
if (((out(b)>-4)&(out(b)<0))|(out(b)==6))
    out1(b)=-1;
else
    out1(b)=1;
end