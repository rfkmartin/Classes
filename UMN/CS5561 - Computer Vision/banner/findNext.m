function dir=findNext(in)

% FINDNEXT(IN)
%
% finds next neighbor of center pixel

if (in(1,1))
    dir=1;
elseif (in(1,2))
    dir=2;    
elseif (in(1,3))
    dir=3;
elseif (in(2,3))
    dir=4;
elseif (in(3,2))
    dir=5;
elseif (in(3,3))
    dir=6;
elseif (in(3,1))
    dir=7;
elseif (in(2,1))
    dir=8;
else
    dir=0;
end