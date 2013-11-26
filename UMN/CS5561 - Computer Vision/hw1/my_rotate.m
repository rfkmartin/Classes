function out=my_rotate(in,phi)

[m,n]=size(in);
new_dim=ceil(sqrt(m*m+n*n));
new_center=ceil(new_dim/2);
out=zeros(new_dim);
mid_x=ceil(m/2);
mid_y=ceil(n/2);

for i=1:m,
   for j=1:n,
      r=sqrt((i-mid_x)^2+(j-mid_y)^2);
      theta=atan2(j-mid_y,i-mid_x);
      x_=ceil(r*cos(phi*pi/180+theta));
      y_=ceil(r*sin(phi*pi/180+theta));
      out(new_center+x_,new_center+y_)=in(i,j);
%      out(new_center-x_,new_center+y_)=in(i,n-j);
%      out(new_center+x_,new_center-y_)=in(m-i,j);
%      out(new_center-x_,new_center-y_)=in(m-i,n-j);
   end
end
