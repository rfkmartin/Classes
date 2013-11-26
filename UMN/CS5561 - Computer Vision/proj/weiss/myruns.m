function out=myruns(in,sz)

% MYRUNS(IN)
%
% converts an image into a list of runs

[a b]=size(in);
regs=zeros(a,b);
for i=1:200,idx(i)=i;end
%idx=[1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 ];
run=struct('start',0,'fin',0,'row',0);
blob=struct('run',0);
blob.run.start=0; % initialize the structure
candidate=0;
runs=1;
on=0;
trow=0;
tstart=0;
%out(1)=[];

for i=1:a,
   for j=1:b,
      %if (i==24)
       %  i
      %end
      
      if (in(i,j)&on)
         if ((i~=1)&(j~=b))
            % check northwest for region not the same as current pixel
            preg=regs(i-1,j+1);
            if (candidate==0)
               candidate=preg;
            elseif ((preg~=0)&(candidate~=preg))
               if (preg>candidate)
                  [none rlens]=size(blob(preg).run);
                  [none rlstart]=size(blob(candidate).run);
                  for k=1:rlens,
                     blob(candidate).run(rlstart+k-1)=blob(preg).run(k);
                     regs(blob(preg).run(k).row,blob(preg).run(k).start:blob(preg).run(k).fin)=candidate;
                  end
                  idx(20)=preg;idx=sort(idx);
                  blob(preg)=struct('run',0);
                  blob(preg).run.start=0; % re-initialize blob
               elseif (preg<candidate)
                  [none rlens]=size(blob(candidate).run);
                  [none rlstart]=size(blob(preg).run);
                  for k=1:rlens,
                     blob(preg).run(rlstart+k-1)=blob(candidate).run(k);
                     regs(blob(candidate).run(k).row,blob(candidate).run(k).start:blob(candidate).run(k).fin)=preg;
                  end
                  idx(20)=candidate;idx=sort(idx);
                  blob(candidate)=struct('run',0);
                  blob(candidate).run.start=0; % re-initialize blob
                  candidate=preg;
               end
            end
         end
               
         if (j==b) % boundary condition
            if (candidate==0)
               candidate=idx(1);
               idx(1)=999;idx=sort(idx);
            end
            
            % initialize new blob if needed
            [none blen]=size(blob);
            if (blen<candidate)
               blob(candidate).run(1).start=0;
            end
            
            [none rlen]=size(blob(candidate).run);
            blob(candidate).run(rlen).start=tstart;
            blob(candidate).run(rlen).row=trow;
            blob(candidate).run(rlen).fin=j;
            blob(candidate).run(rlen+1).start=0;
            regs(trow,tstart:j)=candidate;
            on=0;
            candidate=0;
         end         
      elseif (in(i,j)&~on) % first pixel in run
         trow=i;
         tstart=j;
         on=1;
         
         % check northeast, north, and northwest pixel for region
         if (i~=1)
            if (j~=1) % northeast
               if (regs(i-1,j-1)~=0)
                  candidate=regs(i-1,j-1);
               end
            end
            % north
            if (regs(i-1,j)~=0)
               candidate=regs(i-1,j);
            end
            if (j~=b) % northwest
               if (regs(i-1,j+1)~=0)
                  candidate=regs(i-1,j+1);
               end
            end
         end

         if (j==b) % boundary condition
            if (candidate==0)
               candidate=idx(1);
            end
            
            [none rlen]=size(blob(candidate).run);
            blob(candidate).run(rlen).start=tstart;
            blob(candidate).run(rlen).row=trow;
            blob(candidate).run(rlen).fin=j;
         end
      elseif (~in(i,j)&on)
         if (candidate==0)
            candidate=idx(1);
            idx(1)=999;idx=sort(idx);
         end
         
         % initialize new blob if needed
         [none blen]=size(blob);
         if (blen<candidate)
            blob(candidate).run(1).start=0;
         end
         
         [none rlen]=size(blob(candidate).run);
         blob(candidate).run(rlen).start=tstart;
         blob(candidate).run(rlen).row=trow;
         blob(candidate).run(rlen).fin=j-1;
         blob(candidate).run(rlen+1).start=0;
         regs(trow,tstart:j-1)=candidate;
         on=0;
         candidate=0;
      elseif (~in(i,j)&~on)
         ; % do nothing
      end
   end
end

[a b]=size(blob);
cnt=1;
for i=1:b,
    if (goArea(blob(i))>=sz)
        out(cnt)=blob(i);
        cnt=cnt+1;
    end
end