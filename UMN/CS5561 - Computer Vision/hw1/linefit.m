function [pt]=linefit(line)

% LINEFIT(LINE)
%
% fit an edge list into piecewise
% linear segments

len=line.l;
i=2;
start=1;
pt.vertices=1;
pt.x(pt.vertices)=line.x(1);
pt.y(pt.vertices)=line.y(1);

while (i<len-1)
   dist=ln_dist(line,start,i);
   
   % find point where fitted line deviates by distance of 2
   while (dist<=2)
      i=i+1;
      if (i==len)
         break;
      end      
      dist=ln_dist(line,start,i);
   end
   pt.vertices=pt.vertices+1;
   pt.x(pt.vertices)=line.x(i-1);
   pt.y(pt.vertices)=line.y(i-1);
   start=i-1;
   i=i-1;
end
