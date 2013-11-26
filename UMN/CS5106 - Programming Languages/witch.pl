nextto(1,2).
nextto(2,1).
nextto(1,5).
nextto(5,1).
nextto(3,2).
nextto(2,3).
nextto(4,3).
nextto(3,4).
nextto(5,4).
nextto(4,5).

across(1,4).
across(4,1).
across(1,3).
across(3,1).
across(2,4).
across(4,2).
across(2,5).
across(5,2).
across(3,5).
across(5,3).

leftof(1,2).
leftof(2,3).
leftof(3,4).
leftof(4,5).
leftof(5,1).

rightof(1,2).
rightof(2,3).
rightof(3,4).
rightof(4,5).
rightof(5,1).

tent(quuram,4).
tent(scarrum,X):-tent(quuram,Y),across(X,Y).
tent(oooga,X):-tent(scarrum,Y),leftof(X,Y).
tent(raan,X):-tent(poka,Y),across(X,Y).
tent(poka,X):-tent(scarrum,Y),across(X,Y).

