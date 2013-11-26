function out=connect(in)

% CONNECT(IN)
%
% computes the connectivity of a 3x3 pixel
% group. Counts around the center pixel
% counting color outs. The connectivity
% is one-half that number

out=0;
% North
if (in(1,2)~=in(1,3))
   out=out+1;
end

% Northeast
if (in(1,3)~=in(2,3))
   out=out+1;
end

% East
if (in(2,3)~=in(3,3))
   out=out+1;
end

% Southeast
if (in(3,3)~=in(3,2))
   out=out+1;
end

% South
if (in(3,2)~=in(3,1))
   out=out+1;
end

% Southwest
if (in(3,1)~=in(2,1))
   out=out+1;
end

% West
if (in(2,1)~=in(1,1))
   out=out+1;
end

% Northwest
if (in(1,1)~=in(1,2))
   out=out+1;
end
   
out=out/2;