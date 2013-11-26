function out=edgefollow(in)

% EDGEFOLLOW(IN)
%
% Returns array of linked lists that
% correspond to edges from image IN.

[a b]=size(in);

% Zero pad the image to handle the edges
temp=zeros(a+2,b+2);
temp(2:a+1,2:b+1)=in;
in=temp;

i=2;j=2;
edg=1;
len=1;

while(1)
   while (max(max(in(i,:)))>0),
      while (in(i,j)~=0),
         m=i;n=j;
         E(edg).x(len)=m-1;
         E(edg).y(len)=n-1;
         len=len+1;
         in(m,n)=0;
         
         while (1)
            if (in(m+1,n+1)~=0) %southeast            
               E(edg).x(len)=m;
               E(edg).y(len)=n;
               in(m+1,n+1)=0;
               m=m+1;n=n+1;
               len=len+1;
            elseif (in(m+1,n)~=0) %south
               E(edg).x(len)=m;
               E(edg).y(len)=n-1;
               in(m+1,n)=0;
               m=m+1;
               len=len+1;
            elseif (in(m+1,n-1)~=0) %southwest            
               E(edg).x(len)=m;
               E(edg).y(len)=n-2;
               in(m+1,n-1)=0;
               m=m+1;n=n-1;
               len=len+1;
            elseif (in(m,n-1)~=0) %west
               E(edg).x(len)=m-1;
               E(edg).y(len)=n-2;
               in(m,n-1)=0;
               n=n-1;
               len=len+1;
            elseif (in(m-1,n-1)~=0) %northwest            
               E(edg).x(len)=m-2;
               E(edg).y(len)=n-2;
               in(m-1,n-1)=0;
               m=m-1;n=n-1;
               len=len+1;
            elseif (in(m-1,n)~=0) %north
               E(edg).x(len)=m-2;
               E(edg).y(len)=n-1;
               in(m-1,n)=0;
               m=m-1;
               len=len+1;
            elseif (in(m-1,n+1)~=0) %northeast            
               E(edg).x(len)=m-2;
               E(edg).y(len)=n;
               in(m-1,n+1)=0;
               m=m-1;n=n+1;
               len=len+1;
            elseif (in(m,n+1)~=0) %east
               E(edg).x(len)=m-1;
               E(edg).y(len)=n;
               in(m,n+1)=0;
               n=n+1;
               len=len+1;
            else
               break;
            end
         end
         if (len>=4) % remove edges below this threshold
            E(edg).l=len;
            edg=edg+1;
            len=1;
         else
            len=1;
         end
         
         j=j+1;
         if (j>b)
            break;
         end
         
      end
      
      j=j+1;
      if (j>b)
         j=2;
         break;
      end
   end
   
   i=i+1;
   if (i>a)
      i=2;
      break;
   end    
end

out=E;
