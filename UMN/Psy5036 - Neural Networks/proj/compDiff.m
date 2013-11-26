
function out = compDiff(vData, average, nvehicles)

for n=1:nvehicles,
	diffData(:,n)=reshape(vData(1:480,1+(n-1)*640:n*640)-average,480*640,1);
end

   
out = diffData;
