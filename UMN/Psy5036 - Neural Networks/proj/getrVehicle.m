function out=getrVehicle(vals,avgV,eigV,ncars,ntrucks,nothers)

for j=1:ncars+ntrucks+nothers,
	out(:,j)=reconstructData(avgV,vals,eigV,13,j);
end

