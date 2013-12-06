function out=toInputs(hand1,dealer)

out=zeros(1,77);
for i=1:4,
    out(17*(i-1)+mod(hand1(i)-1,13)+1)=1;
    out(13+17*(i-1)+ceil(hand1(i)/13))=1;
end
out(77)=dealer;
out=out';

