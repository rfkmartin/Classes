function out=cribscore(cards)

% CRIBSCORE
%
% returns the value of a hand for the game of cribbage.
fifteen=0; pair=0; run=0; flush=0; nobs=0;
sortedcards=mod(cards,13);
for i=1:5,
    if (sortedcards(i)==0)
        sortedcards(i)=13;
    end
end
sortedcards=sort(sortedcards);
facecards=(sortedcards<10).*sortedcards+(sortedcards>=10).*10;
suitcards=fix((cards-1)/14);

for i=1:4,
   for j=i+1:5,
      if (facecards(i)+facecards(j)==15) fifteen=fifteen+2;end
      if (sortedcards(i)==sortedcards(j)) pair=pair+2;end
   end
end

for i=1:3,
   for j=i+1:4,
      for k=j+1:5,
         if (facecards(i)+facecards(j)+facecards(k)==15) fifteen=fifteen+2;end
         if ((sortedcards(i)==sortedcards(j)-1)&(sortedcards(j)==sortedcards(k)-1))
            run=run+3;
         end
      end
   end
end

for i=1:2,
   for j=i+1:3,
      for k=j+1:4,
         for l=k+1:5,
            if (facecards(i)+facecards(j)+facecards(k)+facecards(l)==15)
               fifteen=fifteen+2;
            end
            if ((sortedcards(i)==sortedcards(j)-1)&(sortedcards(j)==sortedcards(k)-1)&(sortedcards(k)==sortedcards(l)-1))
               run=run-2;
            end
         end
      end
   end
end

if (sum(facecards)==15)
   fifteen=fifteen+2;
end


for i=1:4,
   if ((suitcards(i)==suitcards(5))&(cards(i)==11)&(cards(5)~=11))
      nobs=1;
   end
end

if (mean(fix(suitcards))==fix(suitcards))
   flush=flush+5;
elseif (mean(fix(suitcards(1:4)))==fix(suitcards(1:4)))
   flush=flush+4;
end

s=sprintf('The score is %d\n', fifteen+run+pair+nobs);
%disp(s)
out=fifteen+run+pair+flush+nobs;
         