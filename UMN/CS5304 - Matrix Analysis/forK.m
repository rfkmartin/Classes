function [x,y,z] = forK(l1,l2,l3,t1d,t2d,t3d)

t1=t1d*pi/180;
t2=t2d*pi/180;
t3=t3d*pi/180;
x=l1*cos(t1)+l2*cos(t1)*cos(t2)+l3*cos(t1)*cos(t2+t3);
y=l1*sin(t1)+l2*sin(t1)*cos(t2)+l3*sin(t1)*cos(t2+t3);
z=l2*sin(t2)+l3*sin(t2+t3);
