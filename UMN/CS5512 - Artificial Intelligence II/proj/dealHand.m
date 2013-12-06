function [hand1,hand2]=dealHand(deck)

for i=1:6,
    hand1(i)=deck(2*i-1);
    hand2(i)=deck(2*i);
end