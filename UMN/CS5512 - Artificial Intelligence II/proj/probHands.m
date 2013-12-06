function [out,out1]=probHands(hand,dealer)

iter=1;
for i=1:5,
    for j=i+1:6,
        newHand=hand;
        newHand(i)=99;newHand(j)=99;
        newHand=sort(newHand);
        newHand=newHand(1:4);
        out(:,iter)=toInputs(newHand,dealer);
        out1(iter,:)=newHand;
        iter=iter+1;
    end
end