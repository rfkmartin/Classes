m(1,1,right,1,2).
m(1,2,right,1,3).
m(1,3,down,2,3).
m(1,3,right,1,4).
m(2,3,down,3,3).
m(3,3,left,3,2).
m(3,2,left,3,1).
m(3,3,right,3,4).
m(3,4,right,3,5).
m(2,3,right,2,4).
m(2,4,right,2,5).
m(2,5,up,1,5).

start(1,1).
goal(1,5).

moves(X):-start(A,B),moves1(A,B,X,_,_).
moves1(A,B,[X|XS],C,D):-m(A,B,X,C,D),moves1(C,D,XS,_,_).
moves1(A,B,[X],C,D):-m(A,B,X,C,D),goal(C,D).
