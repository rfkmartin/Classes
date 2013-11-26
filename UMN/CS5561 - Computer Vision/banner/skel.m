function out=skel(in)

% SKEL(IN)
%
% find the skeleton of a binary image by
% iteratively removing the bounding
% contour.

[a b]=size(in);
count=11;
m=0;

% need to change this to be adaptive
while (count>10)
    count=0;
    m=m+1;
    temp2=zeros(a,b);
    new=zeros(a,b);
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
    temp2(xstart,ystart)=1;
    i=0;
    j=ystart;
    start=1;
    while (1)
        if (start)
            i=xstart;
            start=0;
        end

        if (m==1)
            count=count+1;
            x(count)=i;
            y(count)=j;
        end
        
        % reverse direction
        prev_dstart=dstart;
        dstart=mod(dstart+5,8);
        if (dstart==0)
            dstart=8;
        end
    
        tempi=i;tempj=j;

        % move tempi,j to new point
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
    
        % move clockwise until we find an "on" pixel
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
    
        if (m==1)
            ccode(count)=dstart;
        end
        
        % exit condition
        if ((tempi==xstart)&(tempj==ystart))
            temp2(i,j)=1;
            %figure(1);imshow(temp2);
            %temp2(4:9,102:106),pause;
            if (change)
                %temp2(tempi,tempj)=0;
            end
            %temp2(4:9,102:106)
            break;
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
            change=1;
            if (m~=1)
                count=count-1;
            end
        elseif (temp2(i,j)==0)
            if ((neighbors(temp2(i-1:i+1,j-1:j+1),-1)>1)|...
                    (neighbors(temp2(i-1:i+1,j-1:j+1),1)>1)|...
                    ((neighbors(temp2(i-1:i+1,j-1:j+1),1)==1)&...
                    (neighbors(temp2(i-1:i+1,j-1:j+1),-1)==1)))
                temp2(i,j)=-1;
                change=1;
                if (m~=1)
                    count=count-1;
                end
            else
                temp2(i,j)=1;
                change=0;
                if (m~=1)
                    count=count+1;
                end
            end
        end
        if (mod(count,100)==0)
            %figure(1);imshow(temp2);pause;
        end
    end % while
    
    [a1 b1]=size(x);
    for i=1:b1,
        %new(x(i),y(i))=1;
    end

    if (m==1)
        [l1 c]=lcode(ccode);
        theta=dpp(x,y,c,5);
        l2=maxcurve(theta);
        
        [c d]=size(l2);
        for n=1:d,
            temp2(x(l2(n)),y(l2(n)))=0;
        end
        figure(1);imshow(temp2);
    end
    
    %figure(2);imshow(new)
    %figure(1);imshow(temp2);pause;
    
    % continue to whittle away contour while looking
    % for multiple pixels and noisy pixels
    temp2=temp2==1;
    in=in-temp2;
    %if (count<150)
        %figure(1);imshow(temp2);
        %figure(2);imshow(in);
        %count
        %pause;
        %end
    %count
    figure(2);imshow(in);pause;
end
out=in-temp2;
imshow(out)