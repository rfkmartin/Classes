datatype kind = add|mul|neg|cnst;

datatype 'a  Tree = Empty
	| cnst of 'a 
	| neg of ('a Tree)
	| add of ('a Tree * 'a Tree)
	| mul of ('a Tree * 'a Tree);

val t1 = add(neg(cnst 1),mul(cnst 3,cnst 2));

fun value Empty = 0
	| value (cnst a) = a
	| value (neg(a)) = (~1) * (value(a))
	| value (add(a,b)) = (value(a)) + (value(b))
	| value (mul(a,b)) = (value(a)) * (value(b));