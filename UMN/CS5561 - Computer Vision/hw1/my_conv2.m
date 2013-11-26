function out = my_conv2(template,in)

% out = my_conv2(TEMPLATE,IN)
%
% Performs a 2-D convolution of IN with
% TEMPLATE

[a,b]=size(in);
[c,d]=size(template);

for i=1:a-c,
   for j=1:b-d,
      result=0;
      for k=1:c,
         for l=1:d,
            result=result+in(i+k,j+l).*template(k,l);
         end
      end
      out(i,j)=result;
   end
end
