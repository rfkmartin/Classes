age(john,X):-age(mary,Y),lessThanDiff(X,Y,4).

lessThanDiff(X,Y,Z):-startx(X,Y),lTDr(X,Y,Z).

startx(X,Y):-X is Y.

lTDr(X,Y,Z):-X-Y<Z,X is X + 1,lTDr(X+1,Y,Z).

age(mary,10).
