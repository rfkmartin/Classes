function hw3

x=   [-5 -5  1 -1 -3  5 -3 -2 6  1;
      -8 -3 -6 -4  1  3  2 -2 3 -3];
  
y=   [ 5  5 -1  4  7  7  6  1  1  4;
       2  3 -5  3  2  4  4  0  0  0];
   
test=[-1  1 -8 -5  6  4  5  7 -7 -8;
       0 -2 -5  1  6  1 -5  1  1 -6];

edges=[-8 -6 -4 -2 0 2 4 6 8];

[a b]=size(test);

% Part 1
xb1=histc(x(1,:),edges);
yb1=histc(y(1,:),edges);
tb1=histc(test(1,:),edges);
bar(edges,[xb1;yb1;tb1]');
title('Histogram with scaled distributions');
hold on;

% Compute parzen windows for both sample cases
for i=1:301,
    x1(2,i)=((i-1)/10)-15;
    x1(1,i)=0;
    for j=1:b,
        if (abs((((i-1)/10)-15)-x(1,j))<4)
            x1(1,i)=x1(1,i)+0.0625*(4-abs((((i-1)/10)-15)-x(1,j)));
        end
    end
end

x1(1,:)=x1(1,:)/b;

for i=1:301,
    y1(2,i)=((i-1)/10)-15;
    y1(1,i)=0;
    for j=1:b,
        if (abs((((i-1)/10)-15)-y(1,j))<4)
            y1(1,i)=y1(1,i)+0.0625*(4-abs((((i-1)/10)-15)-y(1,j)));
        end
    end
end

y1(1,:)=y1(1,:)/b;
   
plot(x1(2,:),15*x1(1,:),'b',y1(2,:),15*y1(1,:),'r');
print -djpeg hw31a.jpg
hold off;

% Compute decision for test cases based on bar histograms
for i=1:b,
    if (xb1(floor(test(1,i)/2)+5)>yb1(floor(test(1,i)/2)+5))
        decide(i,1)=1;
    elseif (xb1(floor(test(1,i)/2)+5)<yb1(floor(test(1,i)/2)+5))
        decide(i,1)=-1;
    else
        decide(i,1)=0;
    end
end

% Compute decision based on Parzen windows
for i=1:b,
    if (x1(1,1+10*(test(1,i)+15))>y1(1,1+10*(test(1,i)+15)))
        decide(i,2)=1;
    elseif (x1(1,1+10*(test(1,i)+15))<y1(1,1+10*(test(1,i)+15)))
        decide(i,2)=-1;
    else
        decide(i,2)=0;
    end
end
pause;

% Compute decision line
% the computations were done in Mathematica
for i=1:50,
    f(i,1)=.85*i/50 + 1.35;
    f(i,2)=-14.7689*(0.85*i/50 +1.35)+24.1688;
end

plot(x(1,:),x(2,:),'bo',y(1,:),y(2,:),'r+',test(1,:),test(2,:),'gd');
hold on;
plot(f(:,1),f(:,2),'g-');
title('Class X: o    Class Y: +     Test Cases: diamonds');
print -djpeg hw32a.jpg;
hold off;
pause;

% Compute decisions based on discrimination line
for i=1:b,
    if ((test(2,i)-14.7689*test(1,i)+24.1688)>0)
        decide(i,3)=1;
    else
        decide(i,3)=-1;
    end
end

% Compute decision based on n-nearest neighbors
%
% compute distance between test case and all other points
% sort by distance and count 'nearness' votes for first 'n'
for i=1:b,
    for j=1:b
        dist((j-1)*2+1,1)=sqrt((test(1,i)-x(1,j))^2+(test(2,i)-x(2,j))^2);
        dist((j-1)*2+1,2)=1;
        dist(j*2,1)=sqrt((test(1,i)-y(1,j))^2+(test(2,i)-y(2,j))^2);
        dist(j*2,2)=-1;
    end
    dsum=sortrows(dist);
    if (sum(dsum(1:3,2))>0)
        decide(i,4)=1;
    elseif (sum(dsum(1:3,2))<0)
        decide(i,4)=-1;
    else
        decide(i,4)=0;
    end
end

% Compute 2D Parzen windows
%
% unscaled and left as is from handout. Besides, with equal priors
% we are comparing apples to apples and the exact probability doesn't
% matter.
for j=1:301,
    for i=1:301,
        x2(i,j)=0;
        for k=1:b,
            if (norm([(((i-1)/10)-15)-x(1,k) (((j-1)/10)-15)-x(2,k)])<3)
                x2(i,j)=x2(i,j)+(1/(3*3.14159))*(3-norm([(((i-1)/10)-15)-x(1,k) (((j-1)/10)-15)-x(2,k)]));
            end
        end
    end
end

for j=1:301,
    for i=1:301,
        y2(i,j)=0;
        for k=1:b,
            if (norm([(((i-1)/10)-15)-y(1,k) (((j-1)/10)-15)-y(2,k)])<3)
                y2(i,j)=y2(i,j)+(1/(3*3.14159))*(3-norm([(((i-1)/10)-15)-y(1,k) (((j-1)/10)-15)-y(2,k)]));
            end
        end
    end
end
sum(sum(x2))
sum(sum(y2))

% Make decision based on 2D Parzen windows
for i=1:b,
    if (x2(1+10*(test(1,i)+15),1+10*(test(2,i)+15))>y2(1+10*(test(1,i)+15),1+10*(test(2,i)+15)))
        decide(i,5)=1;
    elseif (x2(1+10*(test(1,i)+15),1+10*(test(2,i)+15))<y2(1+10*(test(1,i)+15),1+10*(test(2,i)+15)))
        decide(i,5)=-1;
    else
        decide(i,5)=0;
    end
end
mesh(x2);
title('Parzen window results for Class X');
print -djpeg hw33a.jpg;
mesh(y2);
title('Parzen window results for Class Y');
print -djpeg hw33b.jpg;
hold off;

disp(' Test Point    | Classification Problem');
disp('k  | ( x, y)   |   1b  1c  2a  2b  2c  ');
disp('-------------------------------------');

for i=1:b,
    r=sprintf('%-2d  | (%-2d,%-2d)  |',i,test(1,i),test(2,i));
    for j=1:5,
        if (decide(i,j)<0)
            r=strcat(r,'   b');
        elseif (decide(i,j)>0)
            r=strcat(r,'   a');
        else
            r=strcat(r,'   X');
        end
    end
    disp(r);
end
