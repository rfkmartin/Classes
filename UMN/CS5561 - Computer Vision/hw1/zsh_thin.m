function out = zsh_thin(in)

% ZS_THIN(IN) returns an image OUT that is
% thinned using the Zhang-Suen-Holt method

[a,b]=size(in);
deleted=1;
iter=0;

i=2;j=2;
while(deleted)
   deleted=0;
   mask=zeros(a,b);
   while(1)
      while (max(max(in(i,:)))>0),
         while (in(i,j)~=0),
         
         % edge of center
         c=connect(in(i-1:i+1,j-1:j+1));
         nb=neighbors(in(i-1:i+1,j-1:j+1));
         edgeC=and(c==1,((nb>=2)&(nb<=6)));
         
         % edge of east
         c=connect(in(i-1:i+1,j:j+2));
         nb=neighbors(in(i-1:i+1,j:j+2));
         edgeE=and(c==1,((nb>=2)&(nb<=6)));
         
         % edge of southeast
         c=connect(in(i:i+2,j:j+2));
         nb=neighbors(in(i:i+2,j:j+2));
         edgeSE=and(c==1,((nb>=2)&(nb<=6)));
         
         % edge of south
         c=connect(in(i:i+2,j-1:j+1));
         nb=neighbors(in(i:i+2,j-1:j+1));
         edgeS=and(c==1,((nb>=2)&(nb<=6)));

         if (not(edgeC)|(edgeE&in(i-1,j)&in(i+1,j))|(edgeS&in(i,j-1)&in(i,j+1))|(edgeE&edgeSE&edgeS))
            mask(i,j)=1; 
            deleted=1;
         end
         
         j=j+1;
         if (j>(b-3))
            break;
         end
         
      end
      
      j=j+1;
      if (j>(b-3))
         j=2;
         break;
      end
      
   end
   
   i=i+1;
   if (i>(a-3))
      i=2;
      break;
   end    
end
   if (not(deleted))
      break;
   end
   in=and(mask,in);
   figure(iter+1);imshow(in)
   iter=iter+1
end

out=in;