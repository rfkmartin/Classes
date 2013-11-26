function [Q,d]=jacobi(A)
% [Q,d] = jacobi(A)
%
% Given a symmetric matrix A, jacobi computes the eignvectors Q and
% eigenvalues d of A by using Classical Jacobi method.

[m,n]=size(A);
Q=eye(n);
off=norm(A,'fro')^2-norm(diag(A))^2;

while off > 10^(-12)
   [stuff,p]=max(max(abs(A'-diag(diag(A)))));
   [stuff,q]=max(max(abs(A-diag(diag(A)))));
   
   if p == q
      [stuff,p]=max(max(abs(triu(A)-diag(diag(A)))));
   end
   
   %[c,s]=sym2(A,p,q);
   
   if A(p,q) ~= 0
   		tau=(A(p,p)-A(q,q))/(2*A(p,q));
   
   		t=sign(tau)/(sqrt(1+tau^2)+abs(tau));
   		c=1/sqrt(1+t^2);
   		s=c*t;
	else
   		c=1;s=0;
   end
   
   J=eye(m);
   J(p,p)=c;
   J(p,q)=-s;
   J(q,p)=s;
   J(q,q)=c;
   
   A=J'*A*J;
   Q=Q*J;
   off=norm(A,'fro')^2-norm(diag(A))^2;
end
d=diag(A);
