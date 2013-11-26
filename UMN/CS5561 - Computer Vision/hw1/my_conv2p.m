function [hor,ver] = my_conv2p(in)

% out = my_conv2s(IN)
%
% Performs an efficient 2-D convolution 
% of IN with a PREWITT template

[a,b]=size(in);

for i=1:a,
   for j=1:b-2,
      hor(i,j)=-in(i,j)+in(i,j+2);
   end
end

for i=1:a-2,
   for j=1:b-2,
      hor(i,j)=hor(i,j)+hor(i+1,j)+hor(i+2,j);
   end
end

for i=1:a,
   for j=1:b-2,
      ver(i,j)=in(i,j)+in(i,j+1)+in(i,j+2);
   end
end

for i=1:a-2,
   for j=1:b-2,
      ver(i,j)=ver(i,j)-ver(i+2,j);
   end
end
