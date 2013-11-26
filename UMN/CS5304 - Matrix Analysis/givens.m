function [A1,Q] = givens(A)

[m,n]=size(A);
Q=eye(m);
A1=A;

for q=2:m,
	for p=1:min(q-1,n),
		c=1/sqrt(1+(A1(q,p)/A1(p,p))^2);
		s=c*A1(q,p)/A1(p,p);
		Eye=eye(m);
		Eye(p,p)=c;
		Eye(p,q)=s;
		Eye(q,p)=-s;
		Eye(q,q)=c;
		A1=Eye*A1;
		Q=Eye*Q;
	end
end
