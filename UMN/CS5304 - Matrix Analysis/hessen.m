function [A,Q] = hessen(A)
% V = hessen(A)
%
% computes the upper Hessenberg for of
% A using Householder transformations

[m,n]=size(A);
Eye=eye(n);
Q=eye(n);

for j=1:n-2,
   u=A(j+1:m,j);
   u1=u-norm(u)*Eye(j+1:m,j+1);
   
   P=eye(n-j)-2*u1*u1'/(u1'*u1);
   
   A(j+1:n,j:n)=P*A(j+1:n,j:n);
   A(1:n,j+1:n)=A(1:n,j+1:n)*P;
   P1=eye(n);
   P1(j+1:n,j+1:n)=P
   Q=Q*P1
end