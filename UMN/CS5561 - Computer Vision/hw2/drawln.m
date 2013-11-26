function drawln(theta,r,maxx,ymax)

if(abs(theta)>.01)
y1=r/sin(theta);
y2=(r-maxx*cos(theta))/sin(theta);
else
    y1=0;
    y2=ymax;
end

line([y1 y2],[0 maxx]);
