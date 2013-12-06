function [s1,s2,input1,input2,net1,net2]=playCribbage(niter,n)

for i=1:52,
   inputs(i,1)=0;inputs(i,2)=1;
end

net1=newff(inputs,[20 1],{'tansig' 'purelin'});
net2=newff(inputs,[20 1],{'tansig' 'purelin'});

% set up networks
%net1=load('cribnet4');
%net2=load('cribnet5');
net1.trainParam.epochs=1;
net1.trainParam.show=NaN;
%net1.trainParam.goal=0.2;
net2.trainParam.epochs=1;
net2.trainParam.show=NaN;
%net2.trainParam.goal=0.2;

% start player one as dealer
dealer1=1;
input1=zeros(52,n);
input2=zeros(52,n);
count=0;
for i=1:niter,
    count=count+1;
    mydeck=deckShuffle(makeDeck);
    
    [hand1 hand2]=dealHand(mydeck);
    hand1=sort(hand1);
    hand2=sort(hand2);
    
    topCard=mydeck(ceil(rand*30)+15);
    [none h1]=probHands(hand1,dealer1);
    [none h2]=probHands(hand2,~dealer1);
    
    for k=1:6,
        input1(hand1(k),count)=1;
        input2(hand2(k),count)=1;
    end

    for j=1:15,
        % scores?
        sc1(j)=cribscore([h1(j,:) topCard]);
        sc2(j)=cribscore([h2(j,:) topCard]);
        sn1(j)=cribscore4(h1(j,:));
        sn2(j)=cribscore4(h2(j,:));
    end
    
    % find max score without cut card
    [v1 m1]=max(sn1);
    [v2 m2]=max(sn2);
    % with cut card
    [v3 m3]=max(sc1);
    [v4 m4]=max(sc2);   
    
    u1=sim(net1,input1(:,count));
    u2=sim(net2,input2(:,count));
    
    % get hand specified by network
    %hand2,u2
    [finalhand1 crib(1:2)]=getHand(hand1,round(u1));
    [finalhand2 crib(3:4)]=getHand(hand2,round(u2));
    %finalhand2
    
    % calculate score
    s1(count,1)=v1;
    s1(count,2)=v3;
    s1(count,3)=cribscore4(finalhand1);
    s1(count,4)=cribscore([finalhand1 topCard]);
    s1(count,5)=sc1(1);
    s1(count,6)=round(u1);
    s1(count,7)=m1;
    s2(count,1)=v2;
    s2(count,2)=v4;
    s2(count,3)=cribscore4(finalhand2);
    s2(count,4)=cribscore([finalhand2 topCard]);
    s2(count,5)=sc2(3);
    s2(count,6)=round(u2);
    s2(count,7)=m4;
    
    c=cribscore([crib topCard]);
    
    if (mod(i,n)==0)
        str=sprintf('chosen hand 1......%d\tchosen hand2......%d',s1(count,3),s2(count,4));
        disp(str);
        str=sprintf('predicted hand 1...%d\tpredicted hand2...%d',v1,v4);
        disp(str);
        
        getCards(hand1);
        getCards(finalhand1);
        getCards(hand2);
        getCards(finalhand2);
        getCards(topCard);
        s=sprintf('iteration %d',i);
        t='training network 1...';
        u='training network 2...';
        disp(s);
        disp(t);
        net1=train(net1,input1,s1(:,7)');
        disp(u);
        net2=train(net2,input2,s2(:,7)');
        count=0;toc
    end

%    if (mod(i-100,50)==0)
%        plotData(s1);
%    end
end
 