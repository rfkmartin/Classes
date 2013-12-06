function out=cribscore4(cards)

% CRIBSCORE
%
% returns the value of a hand for the game of cribbage.
fifteen=0; pair=0; run=0; flush=0; nobs=0;
sortedcards=mod(cards,13);
for i=1:4,
    if (sortedcards(i)==0)
        sortedcards(i)=13;
    end
end
sortedcards=sort(sortedcards);
facecards=(sortedcards<10).*sortedcards+(sortedcards>=10).*10;
suitcards=fix((cards-1)/14);

for i=1:3,
   for j=i+1:4,
      if (facecards(i)+facecards(j)==15) fifteen=fifteen+2;end
      if (sortedcards(i)==sortedcards(j)) pair=pair+2;end
   end
end

for i=1:2,
   for j=i+1:3,
      for k=j+1:4,
         if (facecards(i)+facecards(j)+facecards(k)==15) fifteen=fifteen+2;end
         if ((sortedcards(i)==sortedcards(j)-1)&(sortedcards(j)==sortedcards(k)-1))
            run=run+3;
         end
      end
   end
end

if ((sortedcards(1)==sortedcards(2)-1)&(sortedcards(2)==sortedcards(3)-1)&(sortedcards(3)==sortedcards(4)-1))
    run=run-2;
end

if (sum(facecards)==15)
   fifteen=fifteen+2;
end

if (mean(fix(suitcards))==fix(suitcards))
   flush=flush+4;
end

s=sprintf('The score is %d\n', fifteen+run+pair+nobs);
%disp(s)
out=fifteen+run+pair+flush+nobs;
         