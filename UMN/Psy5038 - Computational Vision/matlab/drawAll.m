function drawAll(data,phi,mag,m,a)

plot(data(:,1),data(:,2),'o')
hold on

mydata=a*phi;
plot(mydata(:,1),mydata(:,2),'r+')

line([-mag*phi(1,1) mag*phi(1,1)],[-mag*phi(1,2) mag*phi(1,2)]);
line([-mag*phi(2,1) mag*phi(2,1)],[-mag*phi(2,2) mag*phi(2,2)]);

axis([-4*m 4*m -4*m 4*m])
hold off