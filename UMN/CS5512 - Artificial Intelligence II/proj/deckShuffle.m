function out=deckShuffle(deck)

out=deck;
for i=1:52,
   j=ceil(rand*52);
   dummy=out(i);
   out(i)=out(j);
   out(j)=dummy;
end

   