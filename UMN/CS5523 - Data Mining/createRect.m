function out=createRect(d,u,l,w)

numPts=d*l*w;
count=0;
while(count <numPts),
    count=count+1;
    foo=rand(1,2) - [0 1];
    out(count,:)=foo.*[l w]+u;
    end,
end
