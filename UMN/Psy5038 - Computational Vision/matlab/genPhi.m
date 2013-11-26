function out = genPhi;

a=rand-0.5;
b=rand-0.5;

out=[a b]/norm([a b]);

a=rand-0.5;
b=rand-0.5;

out(2,:)=[a b]/norm([a b]);
