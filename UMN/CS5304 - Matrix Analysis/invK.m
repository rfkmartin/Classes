function [t1,t2,t3] = invK(l1,l2,l3,x,y,z)

t1=atan2(y,x)*180/pi;
xhat=sqrt(x^2+y^2)-l1;
t3=acos((xhat^2+z^2-l2^2-l3^2)/(2*l2*l3))*180/pi;
beta=atan2(z,xhat);
psi=acos((xhat^2+z^2+l2^2-l3^2)/(2*l2*sqrt(xhat^2+z^2)));
if t3>0
  t2=(beta-psi)*180/pi;
else
  t2=(beta+psi)*180/pi;
end
