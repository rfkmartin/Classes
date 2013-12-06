function [i,j]=playCrib(niter)

out=zeros(10,10,10,10,10,10);
for i=1:niter,
    mydeck=deckShuffle(makeDeck);
    
    [hand1 hand2]=dealHand(mydeck);
    hand1=sort(hand1);
    hand2=sort(hand2);
    
    sortedhand1=mod(hand1,13);
    sortedhand2=mod(hand2,13);
    for i=1:6,
        if (sortedhand1(i)==0)
            sortedhand1(i)=13;
        end
        if (sortedhand2(i)==0)
            sortedhand2(i)=13;
        end
    end
    sortedhand1=sort(sortedhand1);
    sortedhand2=sort(sortedhand2);
    facecards1=(sortedhand1<10).*sortedhand1+(sortedhand1>=10).*10;
    facecards2=(sortedhand2<10).*sortedhand2+(sortedhand2>=10).*10;
    
    out(facecards1(1),facecards1(2),facecards1(3),...
        facecards1(4),facecards1(5),facecards1(6))=...
        out(facecards1(1),facecards1(2),facecards1(3),...
        facecards1(4),facecards1(5),facecards1(6))+1;
    out(facecards2(1),facecards2(2),facecards2(3),...
        facecards2(4),facecards2(5),facecards2(6))=...
        out(facecards2(1),facecards2(2),facecards2(3),...
        facecards2(4),facecards2(5),facecards2(6))+1;

end

[i,j]=find(out);
