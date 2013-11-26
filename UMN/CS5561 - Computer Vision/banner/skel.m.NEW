function [in,l1,l2,x,y]=skel(in)

% SKEL(IN)
%
% find the skeleton of a binary image by
% iteratively removing the bounding
% contour.

[a b]=size(in);
count=1;
m=0;

% continue to peel away contour until extra contour is 0
while (count>0)
    count=1;
    m=m+1;
    temp2=zeros(a,b);
    temp=in;
    xstart=1;

    % find starting point
    while (~max(in(xstart,:)))
        xstart=xstart+1;
    end
    dummy=find(in(xstart,:));
    ystart=dummy(1);

    % find contour
    dstart=4;
    i=0;
    j=ystart;
    start=1;
    while ((i~=xstart)|(j~=ystart))
        if (start)
            i=xstart;
            start=0;
        end
            
    if (count>700)
        rfk=temp2(i-2:i+2,j-2:j+2);
    end
        % reverse direction
        prev_dstart=dstart;
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
                tempi=i+1; % southeast
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
        
        % use lcode once to define significant curvatures
        if (m==1)
            s=sprintf('count %d: d %d x %d y %d\n',count,dstart,i,j);
            l1(count)=dstart;
            x(count)=i;
            y(count)=j;
            %disp(s)
        end
        
        % eliminate multiple pixels by checking for 180 degree turn
        prev_dstart=mod(4+prev_dstart,8);
        if (prev_dstart==0)
            prev_dstart=8;
        end        
        if (prev_dstart==dstart)
            temp2(i,j)=0;
        end
            
        i=tempi;
        j=tempj;
        
        % eliminate multiple pixels by checking for existing pixel in contour
        if (temp2(i,j)==1)
            temp2(i,j)=-1;
            count=count-1;
        elseif (temp2(i,j)==0)
            if ((neighbors0(temp2(i-1:i+1,j-1:j+1))>1))
                temp2(i,j)=-1;
                count=count-1;
            else
                temp2(i,j)=1;
                count=count+1;
            end
        end
    end
    
    if (m==1)
        l1;
        l2=lcode(l1);
    end

    % continue to whittle away contour while looking
    % for multiple pixels and noisy pixels
    temp2=temp2==1;
    in=in-temp2;
    figure(1);imshow(temp2);
    figure(2);imshow(in);
    pause;
    count
end
%figure(1);imshow(temp2);
in=in-temp2;
figure(1);imshow(in);