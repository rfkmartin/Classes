function out = genData(m,n,r)

noise=r*rand(n,1)-(r/2);

out(:,1)=8*rand(n,1)-4;
out(:,2)=m*out(:,1)+noise;

plot(out(:,1),out(:,2),'o')
axis([-4*m 4*m -4*m 4*m])