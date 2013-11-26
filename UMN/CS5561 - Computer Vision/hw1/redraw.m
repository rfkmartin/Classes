function redraw(pts)

% Draws the image given a set of line segments

[m n]=size(pts);

for i=1:n,
   for j=1:pts(i).vertices-1,
      h=line([pts(i).y(j) pts(i).y(j+1)],[pts(i).x(j) pts(i).x(j+1)]);
      set(h,'Marker','+');
   end
end
