function out=ln_dist(line,start,ln_end)

% LN_DIST(LINE)
%
% using the endpoints of line to determine
% a straight line, LINEFIT finds the point
% along the curvilinear line farthest from
% computed line.

max_dist=0;
v=[line.x(start)-line.x(ln_end) line.y(start)-line.y(ln_end)];

for i=start+1:ln_end-1,
   dist=norm(dot([line.y(i)-line.y(start) -line.x(i)+line.x(start)],v))/norm(v);
   if (dist>max_dist)
      max_dist=dist;
   end
end

out=max_dist;