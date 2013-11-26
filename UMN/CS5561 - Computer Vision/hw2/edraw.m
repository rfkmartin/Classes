function edraw(ax,by,x0,y0)

% EDRAW(A,B,X0,Y0)
%
% Uses parametric representation of
% ellipse to draw ellipse with major
% axis A, minor axis B, and centered
% at X0,Y0.

for t=1:100,
   x(t)=(ax)*5*cos(t*pi/50)+5*x0+100;
   y(t)=(by)+*5*sin(t*pi/50)+5*y0+100;
end

for t=1:99,
   line([y(t) y(t+1)], [x(t) x(t+1)]);
end
line([y(100) y(1)],[x(100) x(1)]);
