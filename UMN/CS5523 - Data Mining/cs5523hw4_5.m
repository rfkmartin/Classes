clear
a=[1 2 3;2 4 6;2 2 6;1 1 1;2 2 2];
p=pdist(a);
Z=linkage(p,'single');
dendrogram(Z);
%pause
Z=linkage(p,'complete');
dendrogram(Z);
%pause
count=0;
while(count <150),
    foo=rand(1,2)+[0.5 -1.5];
    if ((foo(1)-1)^2+(foo(2)+1)^2<=0.15),
        count=count+1;
        out2(count,:)=foo;
    end,
end
plot(out2(:,1),out2(:,2),'g*')
hold
count=0;
while(count <150),
    foo=rand(1,2)+0.5;
    if ((foo(1)-1)^2+(foo(2)-1)^2<=0.15),
        count=count+1;
        out1(count,:)=foo;
    end,
end
plot(out1(:,1),out1(:,2),'r*')
count=0;
while(count <1000),
    foo=rand(1,2)*2-1;
    if (foo(1)^2+foo(2)^2<=1),
        count=count+1;
        out(count,:)=foo;
    end,
end,
plot(out(:,1),out(:,2),'b*')
axis equal
[idx C]=kmeans([out;out1;out2],3);
%[idx C]=kmeans([out;out1;out2],[],'Start',[0 0;1 1;1 -1]);
plot(C(1,1),C(1,2),'yo');
plot(C(3,1),C(3,2),'yo');
plot(C(2,1),C(2,2),'yo'),
C
hold

%pause;

count=0;
while(count <50),
    foo=rand(1,2)*2-1;
    if (foo(1)^2+foo(2)^2<=1),
        count=count+1;
        out(count,:)=foo;
    end,
end,
plot(out(:,1),out(:,2),'b*')
hold
count=0;
while(count <2),
    foo=rand(1,2)*2+[2.5 2.5];
    if ((foo(1)-3)^2+(foo(2)-3)^2<=0.1),
        count=count+1;
        out3(count,:)=foo;
    end,
end,
plot(out3(:,1),out3(:,2),'r*')
axis equal
[idx C]=kmeans([out;out3],3);
%[idx C]=kmeans([out;out3],[],'Start',[.1 .1;3.1 3.1]);
plot(C(1,1),C(1,2),'yo');
plot(C(2,1),C(2,2),'yo'),
C
hold

%pause;

count=0;
clear out
while(count <100),
    foo=rand(1,2)*2-1;
    if (foo(1)^2+foo(2)^2<=1),
        count=count+1;
        out(count,:)=foo;
    end,
end,
plot(out(:,1),out(:,2),'b*')
hold
count=0;
clear out4
while(count <10000),
    foo=rand(1,2)*2+[4 4];
    if ((foo(1)-5)^2+(foo(2)-5)^2<=1),
        count=count+1;
        out4(count,:)=foo;
    end,
end,
plot(out4(:,1),out4(:,2),'r*')
[idx C]=kmeans([out;out4],2);
%[idx C]=kmeans([out;out4],[],'Start',[0 0;5 5]);
plot(C(1,1),C(1,2),'yo');
plot(C(2,1),C(2,2),'yo'),
axis equal
C
hold
%pause;
clear out
count=0;
while(count <1000),
    foo=rand(1,2)*2-1;
    if (foo(1)^2+foo(2)^2<=1 && foo(1)^2 +(foo(2)+1)^2>2.25),
        count=count+1;
        out(count,:)=foo;
    end,
end,
plot(out(:,1),out(:,2),'b*')
hold
count=0;
clear out2
while(count <1000),
    foo=rand(1,2)*2-[1.5 1];
    if ((foo(1)+0.5)^2+(foo(2)-0.5)^2<=1 && (foo(1)+0.5)^2 +(foo(2)-1.5)^2>2.25),
        count=count+1;
        out2(count,:)=foo;
    end,
end
plot(out2(:,1),out2(:,2),'r*')
[idx C]=kmeans([out;out2],2);
plot(C(1,1),C(1,2),'yo');
plot(C(2,1),C(2,2),'yo')
axis equal
hold

out=createCircle(3,100,[0 0]);
out1=createCircle(1,100,[5 0]);
out2=createCircle(.25,100,[4 4]);
foo=[out;out1;out2];
p=pdist(foo);
Z=linkage(p,'single');
Z1=linkage(p,'complete');
T=cluster(Z,'MaxClust',3);
T1=cluster(Z1,'MaxClust',3);
scatter(foo(:,1),foo(:,2),10,T,'filled')
axis equal
%pause
scatter(foo(:,1),foo(:,2),10,T1,'filled')
axis equal
%pause
clear
out=createCrescent(1,100,[0 0],[0 -1]);
out1=createCrescent(1,100,[-1.5 -1],[0 1]);
out2=createCrescent(1,100,[1.5 -1],[0 1]);
foo=[out;out1;out2];
p=pdist(foo);
Z=linkage(p,'single');
Z1=linkage(p,'complete');
T=cluster(Z,'MaxClust',3);
T1=cluster(Z1,'MaxClust',3);
scatter(foo(:,1),foo(:,2),10,T,'filled')
axis equal
%pause
scatter(foo(:,1),foo(:,2),10,T1,'filled')
axis equal
%pause
clear
out=createCircle(1,100,[0 0]);
out1=createRect(100,[-1.5 4],3,0.75);
out2=rand(75,2)*4-1;
foo=[out;out1;out2];
p=pdist(foo);
Z=linkage(p,'single');
Z1=linkage(p,'complete');
T=cluster(Z,'MaxClust',2);
T1=cluster(Z1,'MaxClust',2);
scatter(foo(:,1),foo(:,2),10,T,'filled')
axis equal
%pause
scatter(foo(:,1),foo(:,2),10,T1,'filled')
axis equal
%pause
out=createCircle(3,50,[0 0]);
out1=createCircle(.75,500,[4.25 0]);
foo=[out;out1;];
p=pdist(foo);
Z=linkage(p,'single');
Z1=linkage(p,'complete');
T=cluster(Z,'MaxClust',2);
T1=cluster(Z1,'MaxClust',2);
scatter(foo(:,1),foo(:,2),10,T,'filled')
axis equal
%pause
scatter(foo(:,1),foo(:,2),10,T1,'filled')
axis equal
%pause
out=createCircle(3,100,[0 0]);
out1=createCircle(.75,100,[4.25 0]);
foo=[out;out1];
[class,type]=dbscan(foo,5,.25);
scatter(foo(:,1),foo(:,2),10,class,'filled')
axis equal
pause
clear
out=createCircle(3,100,[0 0]);
out1=createCircle(.75,100,[4.25 0]);
foo=[out;out1];
[class,type]=dbscan(foo,5,.539);
scatter(foo(:,1),foo(:,2),10,class,'filled')
axis equal
pause
clear
out=createCircle(3,100,[0 0]);
out1=createCircle(.75,100,[4.25 0]);
out2=rand(750,2).*repmat([8 6],750,1)+repmat([-3 -3],750,1);
foo=[out;out1;out2];
[class,type]=dbscan(foo,5,.25);
scatter(foo(:,1),foo(:,2),10,class,'filled')
axis equal
pause
clear
out=createCircle(3,100,[0 0]);
out1=createCircle(.75,500,[4.25 0]);
out2=rand(500,2).*repmat([8 6],500,1)+repmat([-3 -3],500,1);
foo=[out;out1;out2];
[class,type]=dbscan(foo,5,.25);
scatter(foo(:,1),foo(:,2),10,class,'filled')
axis equal
pause
%clear
out1=createCircle(.75,500,[4.25 0]);
out2=rand(500,2).*repmat([8 6],500,1)+repmat([-3 -3],500,1);
foo=[out;out1;out2];
[class,type]=dbscan(foo,5,.25);
scatter(foo(:,1),foo(:,2),10,class,'filled')
axis equal
pause
