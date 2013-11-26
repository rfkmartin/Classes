function [hist,thresh]=myhisto(in)

% MYHISTO(IN)
%
% Computes histogram of IN and calculates
% threshold value.

[a b]=size(in);
hist=zeros(256,1);
hist1=zeros(256,1);

% make counts
for i=1:a,
   for j=1:b,
      hist1(in(i,j)+1,1)=hist1(in(i,j)+1,1)+1;
   end
end

% smooth
for j=1:5,
   for i=2:255,
      hist(i)=hist1(i-1)+hist1(i)+hist1(i+1);
   end
   hist1=hist;
end

% find peak and threshold
peak=find(hist==max(hist));
valley=peak;
down=1;

% traverse left until 0
for i=peak:-1:1,
   %i,valley,hist(i),hist(valley)
   if ((hist(i)<=hist(valley))&(down~=0))
      valley=i;
      down=1;
   else
      down=0;
   end
end

thresh=valley;

