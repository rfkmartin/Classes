function [hand,crib]=getHand(inhand,idx)

if (idx<1)
    idx=1;
elseif (idx>15)
    idx=15;
end

switch (idx)
case {1}
    hand=inhand(3:6);
    crib=inhand(1:2);
case {2}
    hand=[inhand(2) inhand(4:6)];
    crib=[inhand(1) inhand(3)];
case {3}
    hand=[inhand(2:3) inhand(5:6)];
    crib=[inhand(1) inhand(4)];
case {4}
    hand=[inhand(2:4) inhand(6)];
    crib=[inhand(1) inhand(5)];
case {5}
    hand=inhand(2:5);
    crib=[inhand(1) inhand(6)];
case {6}
    hand=[inhand(1) inhand(4:6)];
    crib=[inhand(2) inhand(3)];
case {7}
    hand=[inhand(1) inhand(3) inhand(5:6)];
    crib=[inhand(1) inhand(4)];
case {8}
    hand=[inhand(1) inhand(3:4) inhand(6)];
    crib=[inhand(2) inhand(5)];
case {9}
    hand=[inhand(1) inhand(3:5)];
    crib=[inhand(2) inhand(6)];
case {10}
    hand=[inhand(1:2) inhand(5:6)];
    crib=[inhand(3) inhand(4)];
case {11}
    hand=[inhand(1:2) inhand(4) inhand(6)];
    crib=[inhand(3) inhand(5)];
case {12}
    hand=[inhand(1:2) inhand(4:5)];
    crib=[inhand(3) inhand(6)];
case {13}
    hand=[inhand(1:3) inhand(6)];
    crib=inhand(4:5);
case {14}
    hand=[inhand(1:3) inhand(5)];
    crib=[inhand(4) inhand(6)];
case {15}
    hand=inhand(1:4);
    crib=inhand(5:6);
otherwise
    hand=inhand(1:4);
    crib=inhand(5:6);
end