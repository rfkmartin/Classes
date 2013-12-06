function plotData1(in)

figure(1)

[a b]=size(in);

tot=0;
for i=1:a,
    tot=tot+in(i,2);
    avg(i)=tot/i;
end
plot(avg,'k-');
avg(a)
hold on;

tot=0;
for i=1:a,
    tot=tot+in(i,4);
    avg(i)=tot/i;
end
plot(avg,'k-.');
avg(a)


legend('Maximum score with cut card','Hand score with cut card')
hold off;