function plotData(in)

figure(1)

[a b]=size(in);

tot=0;
for i=1:a,
    tot=tot+in(i,1);
    avg(i)=tot/i;
end
plot(avg,'b');
avg(a)
hold on;

tot=0;
for i=1:a,
    tot=tot+in(i,2);
    avg(i)=tot/i;
end
plot(avg,'r');
avg(a)

tot=0;
for i=1:a,
    tot=tot+in(i,3);
    avg(i)=tot/i;
end
plot(avg,'g');
avg(a)

tot=0;
for i=1:a,
    tot=tot+in(i,4);
    avg(i)=tot/i;
end
plot(avg,'k');
avg(a)

tot=0;
for i=1:a,
    tot=tot+in(i,5);
    avg(i)=tot/i;
end
plot(avg,'y');
avg(a)

legend('Maximum score without cut card','Maximum score with cut card','Hand score without cut card','Hand score with cut card','Random score with cut card')
hold off;