function out=lhuf(in,rmin,rmax)

% LINE_HOUGH(IN,RMIN,RMAX)
%
% Using the hough transform, finds lines in the
% image IN using the contraints of RMIN and RMAX.
% Lines are fitted using the equation x cos(t)
% +y sin(t) = r.

[m n]=size(in);
vote=zeros(100,rmax-rmin+1);

% get edge direction information
% [mag dir]=sobel(in);

for i=1:m,
   for j=1:n,
      if (in(i,j))
         for theta=1:100,
            r=j*sin(2*pi*theta/100)+i*cos(2*pi*theta/100);
            if ((r>=rmin)&(r<=rmax))
               vote(theta,fix(r)+1)=vote(theta,fix(r)+1)+1;
            end            
         end
      end
   end
end

[i ftheta]=max(max(vote'));
[i fr]=max(max(vote));
j=1;

while (j < 6)
   out(j).theta=ftheta;
   out(j).r=fr;
   % zero out nearby votes to remove duplicates
   vote((ftheta-5)*((ftheta-5)>1)+1:(ftheta+5)*((ftheta+5)<100)+100*((ftheta+5)>=100),(fr-5)*((fr-5)>1)+1:(fr+5)*((fr+5)<rmax)+rmax*((fr+5)>=rmax))=0;
   j=j+1;
   [i ftheta]=max(max(vote'));
   [i fr]=max(max(vote));
end

