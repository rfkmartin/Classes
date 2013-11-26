function out=goPeri1(blob,xsz,ysz,cg,u,v)

[a b]=size(blob.run);

temp=zeros(xsz+2,ysz+2);

% reconstruct
for i=1:b-1;
    temp(blob.run(i).row+1,blob.run(i).start+1:blob.run(i).fin+1)=1;
end
%out=temp;

xstart=blob.run(1).row+1;
ystart=blob.run(1).start+1;
dstart=4;
i=0;
j=ystart;
start=1;
count=0;
umax=0;
umin=0;
vmax=0;
vmin=0;

while ((i~=xstart)|(j~=ystart))
    if (start)
        i=xstart;
        start=0;
    end
    
    % reverse direction
    dstart=mod(dstart+5,8);
    if (dstart==0)
        dstart=8;
    end
    
    tempi=i;tempj=j;
    
    if (dstart==1)
        tempi=i-1; tempj=j-1;%northwest
    elseif (dstart==2)
        tempi=i-1; % north
    elseif (dstart==3)
        tempi=i-1; % northeast
        tempj=j+1;
    elseif (dstart==4)
        tempj=j+1; % east
    elseif (dstart==5)
        tempi=i+1; % souhteast
        tempj=j+1;
    elseif (dstart==6)
        tempi=i+1; % south
    elseif (dstart==7)
        tempi=i+1; % southwest
        tempj=j-1;
    elseif (dstart==8)
        tempj=j-1; % west
    end
    
    while (temp(tempi,tempj)~=1)
        dstart=(mod(dstart+1,8));
        if (dstart==0)
            dstart=8;
        end
        
        tempi=i;tempj=j;
        
        if (dstart==1)
            tempi=i-1; tempj=j-1;%northwest
        elseif (dstart==2)
            tempi=i-1; % north
        elseif (dstart==3)
            tempi=i-1; % northeast
            tempj=j+1;
        elseif (dstart==4)
            tempj=j+1; % east
        elseif (dstart==5)
            tempi=i+1; % souhteast
            tempj=j+1;
        elseif (dstart==6)
            tempi=i+1; % south
        elseif (dstart==7)
            tempi=i+1; % southwest
            tempj=j-1;
        elseif (dstart==8)
            tempj=j-1; % west
        end
    end
    
    i=tempi;
    j=tempj;
    vec=[i-cg.cgx+1 j-cg.cgy+1];
    uprime=u'*vec';
    vprime=v'*vec';
    umax=max(uprime,umax);
    umin=min(uprime,umin);
    vmax=max(vprime,vmax);
    vmin=min(vprime,vmin);
end
out.a=[cg.cgx cg.cgy]'+umax*u+vmax*v;
out.b=[cg.cgx cg.cgy]'+umax*u+vmin*v;
out.c=[cg.cgx cg.cgy]'+umin*u+vmax*v;
out.d=[cg.cgx cg.cgy]'+umin*u+vmin*v;