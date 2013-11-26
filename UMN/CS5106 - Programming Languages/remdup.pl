remdup([H|T],L):-member(H,T),remdup(T,L),!.
remdup([],[]).
remdup([H|T],[H|T1]):-not(member(H,T)),remdup(T,T1),!.



