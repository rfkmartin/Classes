function ehuf(in)

% EHUF(IN)
%
% Using the hough transform, finds ellipses in the
% image IN.

tic
[m n]=size(in);
vote=zeros(16,21,35,70);

% get edge direction information
% 9x9 Sobel for better angular resolution
sob=[-1 -2 -3  -5 0 5 3 2 1;
   -2 -3 -5 -8 0 8 5 3 2;
   -3 -5 -8 -13 0 13 8 5 3;
   -5 -8 -13 -21 0 21 13 8 5;
   -8 -13 -21 -34 0 34 21 13 8;
   -5 -8 -13 -21 0 21 13 8 5;
   -3 -5 -8 -13 0 13 8 5 3;
   -2 -3 -5 -8 0 8 5 3 2;
	-1 -2 -3  -5 0 5 3 2 1];
ver=filter2(sob,in);
hor=filter2(-sob',in);
phi=atan2(hor,ver);
mask=in&(ver|hor); % remove non-edge areas
[i,j]=find(mask==1);
[len,junk]=size(i);

for t=1:5:len,
   t
   for k=5:5:80, % a
      for l=40:5:140, % b
         %theta
         if (abs(cos(phi(i(t),j(t))))==1)
            x0(1)=i(t)+k;
            x0(2)=i(t)-k;
            y0(1)=j(t);
            y0(2)=j(t);
         elseif (abs(sin(phi(i(t),j(t))))==1)
            %phi(i(t),j(t)),i(t),j(t)
            x0(1)=i(t);
            x0(2)=i(t);
            y0(1)=j(t)+l;
            y0(2)=j(t)-l;
         else
            x0(1)=i(t)+k/(sqrt(1+l^2/(k^2*tan(phi(i(t),j(t)))^2)));
            x0(2)=i(t)-k/(sqrt(1+l^2/(k^2*tan(phi(i(t),j(t)))^2)));
            y0(1)=j(t)+l/(sqrt(1+(k^2*tan(phi(i(t),j(t)))^2)/l^2));
            y0(2)=j(t)-l/(sqrt(1+(k^2*tan(phi(i(t),j(t)))^2)/l^2));
         end
         
         % shrink param space
         x0=round((x0-100)/5);
         y0=round((y0-100)/5);
         
         for u=1:2,
            if ((x0(u)>0)&(x0(u)<=35)&(y0(u)>0)&(y0(u)<=70))
               %i(t),j(t),phi(i(t),j(t))
               %t,x0,y0,k/5,l/5-7,phi(i(t),j(t))
               vote(k/5,l/5-7,x0(u),y0(u))=vote(k/5,l/5-7,x0(u),y0(u))+1;
            end
         end
      end
   end
   %i
end
out=vote;
toc

e1=max(max(max(max(vote))));
[i ind]=find(vote==e1);
g(1,:)=desub(i,ind);
j=1;

while (j < 10)
   % zero out nearby votes to remove duplicates
   vote(g(j,1):g(j,1)+1,g(j,2):g(j,2)+1,g(j,3):g(j,3)+1,g(j,4):g(j,4)+1)=0;
   j=j+1;
   e1=max(max(max(max(vote))));
   [i ind]=find(vote==e1);
   g(j,:)=desub(i(1),ind(1));
end

%imshow(ones(m,n))
for t=1:5,
   edraw(g(t,1),g(t,2),g(t,3),g(t,4));
end
