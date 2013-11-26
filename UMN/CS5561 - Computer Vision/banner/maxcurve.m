function out=maxcurve(theta)

[maxt y]=max(theta);
i=1;
tooclose=0;

while (maxt>0.75)
    for j=1:i-1,
        if (abs(y-out(j))<5)
            tooclose=1;
            theta(y)=0;
        end
    end
    
    if (~tooclose)
        out(i)=y;
        theta(y)=0;
        i=i+1;
    end
    tooclose=0;
    [maxt y]=max(theta);
end