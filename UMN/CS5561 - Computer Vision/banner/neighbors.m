function out=neighbors(in,n)

% NEIGHBORS(IN)
%
% computes number of neighbors that
% match N of 3x3 pixel group based
% on 8-connectivity

out=0;
for k=1:3,
	for l=1:3,
		if ((k~=2)|(l~=2))
			if (in(k,l)==n)
				out=out+1;
			end
		end
	end
end