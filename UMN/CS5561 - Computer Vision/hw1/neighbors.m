function out=neighbors(in)

% NEIGHBORS(IN)
%
% computes number of neighbors of
% 3x3 pixel group based on
% 8-connectivity

out=0;
for k=1:3,
	for l=1:3,
		if ((k~=2)|(l~=2))
			if (in(k,l)~=0)
				out=out+1;
			end
		end
	end
end