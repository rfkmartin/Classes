aisle(tort,X):-X=1;X=2;X=3;X=4;X=5;X=6;X=7;X=8;X=9;X=10;X=11;X=12;X=13;X=14;X=15;X=16;X=17;X=19;X=20.
aisle(succ,X):-X=1;X=2;X=3;X=5;X=6;X=7;X=8;X=9;X=10;X=11;X=12;X=13;X=14;X=15;X=16;X=17;X=18;X=19;X=20.
aisle(pie,2).
aisle(mac,7).
aisle(_,X):-X=1;X=2;X=3;X=4;X=5;X=6;X=7;X=8;X=9;X=10;X=11;X=12;X=13;X=14;X=15;X=16;X=17;X=18;X=19;X=20.

aisle(ben,X):-not(aisle(tort,X)),not(aisle(tort,18)).
aisle(ben,X):-aisle(mac,X).
aisle(succ,X):-not(aisle(pie,X)).

aisle(carolyn,X):-not(aisle(tort,X)).
aisle(tort,X):-aisle(succ,Y),abs(X-Y)>12.
aisle(succ,X):-aisle(ben,Y),Y-X>0.

aisle(tort,X):-X=17;X=18;X=19.
aisle(carolyn,X):-aisle(mac,Y),X+4=Y;X+5=Y.
aisle(ed,X):-not(aisle(pie,X)).

aisle(tara,X):-aisle(mac,X).
aisle(tara,X):-aisle(pie,Y),abs(X-Y)=\=1;abs(X-Y)<7.
aisle(ed,X):-aisle(succ,X).

