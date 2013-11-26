function out=removeSpur(in,skel)

% REMOVESPUR(IN)
%
% removes spurs from MAT using criteria
% of maximal circles for each pixel.

[a b]=size(in);

for i=1:a,
    for j=1:b,
        if (skel(i,j)==1) % part of MAT
            % find next neighbor and check distance
            if (skel(i+1,j+1)>0) %southeast
                if (~in(i-1,j+1)&~in(i+1,j-1))
                    direction=5;
                    keep=1;
                else
                    direction=5;
                    keep=0;
                end                
            elseif (skel(i+1,j)>0) %south
                if (~in(i,j+1)&~in(i,j-1))
                    direction=6;
                    keep=1;
                else
                    direction=6;
                    keep=0;
                end   
            elseif (skel(i+1,j-1)>0) %southwest            
                if (~in(i-1,j-1)&~in(i+1,j+1))
                    direction=7;
                    keep=1;
                else
                    direction=7;
                    keep=0;
                end   
            elseif (skel(i,j-1)>0) %west
                if (~in(i-1,j)&~in(i+1,j))
                    direction=8;
                    keep=1;
                else
                    direction=8;
                    keep=0;
                end   
            elseif (skel(i-1,j-1)>0) %northwest            
                if (~in(i-1,j+1)&~in(i+1,j-1))
                    direction=1;
                    keep=1;
                else
                    direction=1;
                    keep=0;
                end   
            elseif (skel(i-1,j)>0) %north
                if (~in(i,j+1)&~in(i,j-1))
                    direction=2;
                    keep=1;
                else
                    direction=2;
                    keep=0;
                end   
            elseif (skel(i-1,j+1)>0) %northeast            
                if (~in(i-1,j-1)&~in(i+1,j+1))
                    direction=3;
                    keep=1;
                else
                    direction=3;
                    keep=0;
                end   
            elseif (skel(i,j+1)>0) %east
                if (~in(i-1,j)&~in(i+1,j-1))
                    direction=4;
                    keep=1;
                else
                    direction=4;
                    keep=0;
                end   
            else
               break;
            end
            
            if ((~keep)&(neighbors(skel(i-1:i+1,j-1:j+1),-1)>0))
                keep=1;
            end
            
            m=i;n=j;
            next=1;
            while (next)
                if (keep)
                    skel(m,n)=-1;
                else
                    skel(m,n)=0;
                end
                
                % get new point for current direction
                switch (direction)
                case {1}
                    m=m-1;n=n-1;
                    next=skel(m-1,n-1);
                case {2}
                    m=m-1;
                    next=skel(m-1,n);
                case {3}
                    m=m-1;n=n+1;
                    next=skel(m-1,n+1);
                case {4}
                    n=n+1;
                    next=skel(m,n+1);
                case {5}
                    m=m+1;n=n+1;
                    next=skel(m+1,n+1);
                case {6}
                    m=m+1;
                    next=skel(m+1,n);
                case {7}
                    m=m+1;n=n-1;
                    next=skel(m+1,n-1);
                case {8}
                    n=n-1;
                    next=skel(m,n-1);
                end
                    
                % check # of neighbors
                nbrs=neighbors(skel(m-1:m+1,n-1:n+1),1);
                
                if ((nbrs==1)&(~next))
                    direction=findNext(skel(m-1:m+1,n-1:n+1));
                end
                
                if ((nbrs>=2)|(nbrs==0))
                    next=0;
                    if (keep)
                        skel(m,n)=-1;
                    else
                        skel(m,n)=0;
                    end
                end
            end
            %figure(1);imshow(skel>0);
            %figure(2);imshow(skel<0);
            %pause;
        end
    end
end
figure(1);imshow(skel>0);
figure(2);imshow(skel<0);
out=skel;