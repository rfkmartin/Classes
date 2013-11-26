function [temp2,count,area]=goPeri(blob)

[a b]=size(blob.run);

mbr=goMBR(blob);
height=mbr.xmax-mbr.xmin;
width=mbr.ymax-mbr.ymin;
temp=zeros(height+3,width+3);
temp2=temp;

% reconstruct
for i=1:b-1;
    temp(blob.run(i).row-mbr.xmin+2,blob.run(i).start-mbr.ymin+2:blob.run(i).fin-mbr.ymin+2)=1;
end
%out=temp;

xstart=blob.run(1).row-mbr.xmin+2;
ystart=blob.run(1).start-mbr.ymin+2;
dstart=4;
i=0;
j=ystart;
start=1;
count=0;
xpos=1;
area=0;

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
    temp2(i,j)=1;
    count=count+1;
    
    switch (dstart)
    case {1}
        area=area-xpos;
        xpos=xpos-1;
    case {2}
        area=area-xpos;
    case {3}
        area=area-xpos;
        xpos=xpos+1;
    case {4}
        xpos=xpos+1;
    case {5}
        area=area+xpos;
        xpos=xpos+1;
    case {6}
        area=area+xpos;
    case {7}
        area=area+xpos;
        xpos=xpos-1;
    case {8}
        xpos=xpos-1;
    end
    
end
%out=count;