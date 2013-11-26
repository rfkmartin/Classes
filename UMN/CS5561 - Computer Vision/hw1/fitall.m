function pt=fitall(lines)

% FITALL(LINES)
%
% Given a list of edges,
% decompose them into a series
% of lines. Outputs a list of
% lines described by their vertices

[m n]=size(lines);

for i=1:n,
   pt(i)=linefit(lines(i));
end

