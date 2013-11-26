function out=projectTest(test, avg, eigenV, neigen)

for k=1:neigen,
	out(k)=dot(eigenV(:,k),reshape(test,480*640,1)-reshape(avg,480*640,1));
end
