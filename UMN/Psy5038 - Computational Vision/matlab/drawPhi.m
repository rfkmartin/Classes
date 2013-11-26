function drawPhi(phi,mag,m)

line([-mag*phi(1,1) mag*phi(1,1)],[-mag*phi(1,2) mag*phi(1,2)]);
line([-mag*phi(2,1) mag*phi(2,1)],[-mag*phi(2,2) mag*phi(2,2)]);

axis([-4*m 4*m -4*m 4*m])