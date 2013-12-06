function getCards(deck)

[a b]=size(deck);

for i=1:b,
   rank=mod(deck(i),13);
   suit=ceil(deck(i)/13);
   
   switch (rank)
   case {1}
      r='Ace of ';
   case{11}
      r='Jack of';
   case{12}
      r='Queen of';
   case{0}
      r='King of';
   otherwise
      r=sprintf('%d of', rank);
   end
   
   switch (suit)
   case{1}
      s=' Spades';
   case{2}
      s=' Clubs';
   case{3}
      s=' Diamonds';
   case{4}     
      s=' Hearts';
   end
   disp([r s])
end
disp('--------');
