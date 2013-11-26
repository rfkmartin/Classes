function out = zs_thin(in)

% ZS_THIN(IN) returns an image OUT that is
% thinned using the Zhang-Suen method

[a,b]=size(in);
deleted=1;

i=2;j=2;

while(deleted)
   deleted=0;
   mask=ones(a,b);
   while(1)
      while (max(max(in(i,:)))>0),
         while (in(i,j)~=0),
            
            % check for connectivity
            connectivity=connect(in(i-1:i+1,j-1:j+1));
            
            % check for neighbors
            nb=neighbors(in(i-1:i+1,j-1:j+1));
                        
            if (connectivity==1&((nb>=2)&(nb<=6))&(~in(i,j+1)|~in(i-1,j)|~in(i,j-1))&(~in(i-1,j)|~in(i+1,j)|~in(i,j-1)))
               mask(i,j)=0;
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
   
   % End of first subiteration
   in=and(mask,in);
   mask=ones(a,b);
   
   while(1)
      while (max(max(in(i,:)))>0),
         while (in(i,j)~=0),
            
            % check for connectivity
            connectivity=connect(in(i-1:i+1,j-1:j+1));
            
            % check for neighbors
            nb=neighbors(in(i-1:i+1,j-1:j+1));
                        
            if (connectivity==1&((nb>=2)&(nb<=6))&(~in(i,j+1)|~in(i+1,j)|~in(i,j-1))&(~in(i-1,j)|~in(i+1,j)|~in(i,j+1)))
               mask(i,j)=0;
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
   
   % End of second subiteration
   in=and(mask,in);
   
   if (not(deleted))
      break;
   end
end
out=in;