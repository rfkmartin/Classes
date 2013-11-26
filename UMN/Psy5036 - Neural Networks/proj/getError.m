function out=getError(rvehicle,nvehicles,vehicle)

for j=1:nvehicles,
	out(j)=norm((reshape(rvehicle(:,j),480,640)-vehicle(1:480,1+(j-1)*640:j*640))/vehicle(1:480,1+(j-1)*640:j*640));
end
