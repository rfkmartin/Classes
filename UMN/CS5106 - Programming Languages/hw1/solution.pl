% A membership relation.
% Usage example: mem(1,[2,4,1,3])
mem(X,[X|_]).
mem(X,[Y|L]) :- mem(X,L).

% A subset relation.
% Usage example: subs([1,2],[3,2,4,1,5])
subs([],_).
subs([X|XS],L) :- mem(X,L), subs(XS,L).

% A prefix relation.
% Usage example: prefix([1,2],[1,2,3,4])
prefix([],_).
prefix([X|XS],[X|YS]):- prefix(XS,YS).

% A sublist relation
% Usage example: sublist([1,2],[3,4,1,2]).
sublist([],_).
sublist(XS,YS) :- prefix(XS,YS).
sublist(X,[_|YS]) :- sublist(X,YS).
