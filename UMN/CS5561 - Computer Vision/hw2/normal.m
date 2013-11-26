function out = normal(in,least,most)

% NORMAL(IN,MIN,MAX)
%
% takes a matrix IN and normalizes it between
% min and max

nmin=min(min(in));
nmax=max(max(in));

out=least+((in-nmin)/(abs(nmin)+nmax))*(most-least);