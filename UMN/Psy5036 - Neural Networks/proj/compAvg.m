function out=compAvg(vData,nvehicles)

temp = zeros(480,640);

for n=1:nvehicles,
   temp=temp+vData(1:480,1+(n-1)*640:n*640);
end

out=temp/n;
