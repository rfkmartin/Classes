function out=projectData(data, avg, eigenV, neigen, nvehicles)

for j=1:nvehicles,
   for k=1:neigen,
      out(j,k)=dot(eigenV(:,k),reshape(data(1:480,1+(j-1)*640:j*640),480*640,1)-reshape(avg,480*640,1));
   end
end
