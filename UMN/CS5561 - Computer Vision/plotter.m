function plotter(a,b,c)

for i=1:100,
    t=i*2*pi/100;
    cs(i)=cos(2*t)*cos(2*t);
    ss(i)=1-sin(2*t)*sin(2*t);
    el(i)=a*sin(t)^2-b*sin(t)*cos(t)+c*cos(t)^2;
    del(i)=(a-c)*sin(2*t)-b*cos(2*t);
end

d=atan(b/(a-c))/2
a*sin(d)^2-b*sin(d)*cos(d)+c*cos(d)^2
(a-c)*sin(2*d)-b*cos(2*d)

plot(ss,'o'),hold on;
plot(cs,'r+')
hold off;