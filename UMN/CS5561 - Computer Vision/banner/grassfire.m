function [out1,out2,out3]=grassfire(name,redux)

% GRASSFIRE(IN)
%
% performs a medial axis transform(MAT)
% of given image

% define filters
smooth=[1 2 1;2 4 2;1 2 1];
dilate=[1 1 1;1 1 1;1 1 1];

% load image
fname=sprintf('images/%s.bmp',name);
[X,MAP]=imread(fname);
in=(ind2gray(X,MAP));
figure(1);imshow(in);
in=round(in*255);

% smooth and normalize image
in=filter2(smooth,in);
in=round(normal(in,0,255));

% threshold image
thresh=myhisto(in);

% reduce resolution by factor of 8
in=lo_res(in,redux);

% binarize and shrink/expand image
in=in>thresh;
%for i=1:2,
    in=filter2(dilate,in)>0;
%    in=zs_thin1(in);
%end

% create output matrices
[m n]=size(in);
temp=ones(m,n);
out=zeros(m,n);

% Hack to take into account objects
% that border the edge -- can be
% removed.
temp1=zeros(m-2,n-2);
temp(2:m-1,2:n-1)=temp1;
temp=temp&in;

% Top left corner to bottom right
for i=2:m-1,
   for j=2:n-1,
      if (in(i,j))
         %find min
         min=temp(i,j-1);
         if (temp(i-1,j-1) < min)
            min=temp(i-1,j-1);
         end
         if (temp(i-1,j) < min)
            min=temp(i-1,j);
         end
         if (temp(i-1,j+1) < min)
            min=temp(i-1,j+1);
         end         
         temp(i,j)=1+min;
      end
   end
end

% Bottom right corner to top left
for i=m-1:-1:2,
   for j=n-1:-1:2,
      if (in(i,j))
         %find min
         min=temp(i,j);
         if ((1+temp(i,j+1))<min)
            min=1+temp(i,j+1);
         end
         if ((1+temp(i+1,j+1))<min)
            min=1+temp(i+1,j+1);
         end
         if ((1+temp(i+1,j))<min)
            min=1+temp(i+1,j);
         end
         if ((1+temp(i+1,j-1))<min)
            min=1+temp(i+1,j-1);
         end         
         temp(i,j)=min;
      end
   end
end
out1=in;

% Using 4-connectivity, a point is considered part of the skeleton
% if it is as large or larger(in distance value) than all of its neigbors

%for i=2:m-1,
%   for j=2:n-1,
%      if (temp(i,j)~=0)
%          if ((temp(i,j)>=temp(i,j-1))&(temp(i,j)>=temp(i-1,j))&(temp(i,j)>=temp(i,j+1))&(temp(i,j)>=temp(i+1,j)))
%              out(i,j)=1;
%          end
%      end
%end
%end


% Now look for points of maximum curvature
% in distance transform. Assuming 8-connectivity
% maximum curvature can be found by marking
% all points whose neighbors contain one or
% fewer pixels with a distance one greater than
% the pixel being looked at.

around=[0 0 0];
for i=2:m-1,
   for j=2:n-1,
      if (temp(i,j)~=0)
         for k=1:3,
            for l=1:3,
               if (((k~=2)|(l~=2))&(temp(i,j)~=0))
                  around(temp(i,j)-temp(i+k-2,j+l-2)+2)=around(temp(i,j)-temp(i+k-2,j+l-2)+2)+1;
              end
          end
      end
         if ((around(1)<=1)&(temp(i,j)~=0))
            out(i,j)=1;
        end
    end
      around=[0 0 0];
  end
end
%figure(2);imshow(not(in)|out);
%figure(3);imshow(removeSpur(in,out))
out=zs_thin(out);
figure(2);
iptsetpref('ImshowAxesVisible','on');
imshow(not(in)|out);
%out3=temp;
out3=bwmorph(in,'skel',Inf);
figure(3);imshow(not(in)|out3);
out2=out;
