function out=toInputs6(hand1,dealer)

out=zeros(1,103);
for i=1:6,
    out(17*(i-1)+mod(hand1(i)-1,13)+1)=1;
    out(13+17*(i-1)+ceil(hand1(i)/13))=1;
end
out(103)=dealer;
out=out';

