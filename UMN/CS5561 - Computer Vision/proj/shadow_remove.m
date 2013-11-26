function out=shadow_remove(in,template)

mask=not(template)*999;
in1=in+mask;
i=find(in1<999);
summ=sum(sum(in.*template));
avg=0.15*summ/length(i);

[shad(:,1),shad(:,2)]=find(in1<avg);
[veh(:,1),veh(:,2)]=find(in1>=avg&in1<999);

[a,b]=size(shad);
[c,d]=size(veh);

% fill array with current edge values
for i=1:a,
    shad(i,3)=in(shad(i,1),shad(i,2));
end

for i=1:c,
    veh(i,3)=in(veh(i,1),veh(i,2));
end

% find starting values
shad_avg=mean(shad);
veh_avg=mean(veh);

% mixing constants
alpha=0.6;
beta=0.4;

% stopping condition
counter=11;

while(counter>10),
    counter=0;
    shad_cnt=1;
    veh_cnt=1;
    
    %temp1=zeros(size(in));
    %for i=1:a,
    %    temp1(shad(i,1),shad(i,2))=1;
    %end
    %temp2=zeros(size(in));
    %for i=1:c,
    %    temp2(veh(i,1),veh(i,2))=1;
    %end
     
    %figure(5);imshow(temp1);
    %figure(6);imshow(temp2);pause;
    
    for i=1:a,
        if ((alpha*((shad(i,1)-shad_avg(1))^2+(shad(i,2)-shad_avg(2))^2)^1/2+...
            beta*(shad(i,3)-shad_avg(3)))<(alpha*((shad(i,1)-veh_avg(1))^2+...
                (shad(i,2)-veh_avg(2))^2)^1/2+beta*(shad(i,3)-veh_avg(3)))),
            shad_temp(shad_cnt,:)=shad(i,:);
            shad_cnt=shad_cnt+1;
        else
            veh_temp(veh_cnt,:)=shad(i,:);
            veh_cnt=veh_cnt+1;
            counter=counter+1;
        end
    end
        
    for i=1:c,
        if ((alpha*((veh(i,1)-veh_avg(1))^2+(veh(i,2)-veh_avg(2))^2)^1/2+...
            beta*(veh(i,3)-veh_avg(3)))<(alpha*((veh(i,1)-shad_avg(1))^2+...
                (veh(i,2)-shad_avg(2))^2)^1/2+beta*(veh(i,3)-shad_avg(3)))),
            veh_temp(veh_cnt,:)=veh(i,:);
            veh_cnt=veh_cnt+1;
        else
            shad_temp(shad_cnt,:)=veh(i,:);
            shad_cnt=shad_cnt+1;
            counter=counter+1;
        end
    end
        
    shad=shad_temp;
    shad_prevn=norm(shad_avg);
    shad_avg=mean(shad);
    shad_postn=norm(shad_avg);
    [a,b]=size(shad);

    veh=veh_temp;
    veh_prevn=norm(veh_avg);
    veh_avg=mean(veh);
    veh_postn=norm(veh_avg);
    [c,d]=size(veh);
    
    counter
    
    % exit the loop if neither shadow nor vehicle exist
    if (isnan(shad_avg)|isnan(veh_avg))
        counter=0;
    end
    
    % exit the loop if the clusters are changing little
    if (abs((shad_prevn-shad_postn)/shad_prevn)<0.05)
        counter=0;
    end
    
    if (abs((veh_prevn-veh_postn)/veh_prevn)<0.05)
        counter=0;
    end
    
end
out=zeros(size(in));
for i=1:c,
    out(veh(i,1),veh(i,2))=1;
end
%imshow(out);pause;