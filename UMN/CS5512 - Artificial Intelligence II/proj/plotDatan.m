function plotDatan(in,n)

figure(1)

[a b]=size(in);

tot=zeros(5,a-n);
for i=1:a-n,
    for j=1:n,
        tot(1,i)=tot(1,i)+in(i+j-1,1);
        tot(2,i)=tot(2,i)+in(i+j-1,2);
        tot(3,i)=tot(3,i)+in(i+j-1,3);
        tot(4,i)=tot(4,i)+in(i+j-1,4);
        tot(5,i)=tot(5,i)+in(i+j-1,5);
    end
end

avg=tot/n;
plot(avg(1,:),'b');
hold on;
plot(avg(2,:),'r');
hold on;
plot(avg(3,:),'g');
hold on;
plot(avg(4,:),'k');
hold on;
plot(avg(5,:),'y');
legend('Maximum score without cut card','Maximum score with cut card','Hand score without cut card','Hand score with cut card','Random score with cut card')
hold off;