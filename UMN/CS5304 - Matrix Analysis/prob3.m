function [A,Q,J] = prob3(A)
% [Q,J,V] = prob(A)
%
% computes orthogonal Q, J so that
% V = QAJ is lower biagonal and returns
% that matrix

[m,n]=size(A);
Eye=eye(n);
Q=eye(n);
J=eye(n);

for j=1:n-1,
   if j==1, % for the first iteration, we do not need to compute Householder
      P=eye(n);
   else % computer Q
	   u=A(j:m,j-1);
      u1=u-norm(u)*Eye(j:m,j);
      P=eye(n-j+1)-2*u1*u1'/(u1'*u1);
      P1=eye(n);
      P1(j:m,j:m)=P;
      A=P1*A;
      Q=P1*Q; % Q=Qi*Q
   end
   
   % compute Householder for J
   v=A(j,j:m);
   v1=v'-norm(v)*Eye(j:m,j);
   P=eye(n-j+1)-2*v1*v1'/(v1'*v1);
   P1=eye(n);
   P1(j:m,j:m)=P;
   
   A=A*P1;
   J=J*P1; % J=J*Ji
end