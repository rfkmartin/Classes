function out=goHolecnt(in)

% goHolecnt(IN)
%
% counts holes in the image

[a b]=size(in);

% region labeling matrix
regs=zeros(a,b);

% up to 20 holes
for i=1:20,idx(i)=i;end

candidate=0;
on=0;

for i=1:a,
   for j=1:b,

      if (in(i,j)&on)
          regs(i,j)=-1; % do nothing
      elseif (in(i,j)&~on)
          regs(i,j)=-1;
          on=1;
          candidate=idx(1);idx(1)=999;idx=sort(idx);
      elseif (~in(i,j)&on)
          % check northeast, north, and northwest pixel for hole labeling
          if (regs(i-1,j-1)>=0) %northwest
              idx(20)=candidate;idx=sort(idx);
              candidate=regs(i-1,j-1);
          elseif (regs(i-1,j)>=0) %north
              idx(20)=candidate;idx=sort(idx);
              candidate=regs(i-1,j);
          elseif (regs(i-1,j+1)>=0) %northeast
              idx(20)=candidate;idx=sort(idx);
              candidate=regs(i-1,j+1);
          end
          regs(i,j)=candidate;
          on=0;
      elseif (~in(i,j)&~on)          
          %label holes
          % check northeast for region not the same as current pixel
          if ((i~=1)&(j~=b))
              preg=regs(i-1,j+1);
              if ((preg>0)&(candidate~=preg))
                  if (preg>candidate)
                      idx(20)=preg;idx=sort(idx);                  
                  elseif (preg<candidate)
                      idx(20)=candidate;idx=sort(idx);
                      candidate=preg;
                  end
              end
          end
          if (j==b)
              if (candidate~=0)
                  idx(20)=candidate;idx=sort(idx);
                  candidate=0;
              end
          end
          regs(i,j)=candidate;
          on=0;
      end
   end
end
out=idx(1)-1;