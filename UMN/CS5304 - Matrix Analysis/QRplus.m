function [Qplus,Rplus] = QRplus(A)
[m,n]=size(A);
Eye=eye(m,n);

% Keep track of R matrices
Rplus=A;
Rminus=A;

% Keep track of Q matrices
Qplus=eye(m);
Qminus=eye(m);

for i=1:min(m,n),
   % calculate u vectors
   % u = u - ||u||
   % v = v + ||v||
   u=Rminus(i:m,i);
   u1=u-norm(u)*Eye(i:m,i);
   %u1=max(abs(u1), eps);
	v=Rplus(i:m,i);
   v1=v+norm(v)*Eye(i:m,i);
   %v1=max(abs(v1),eps);
   
   % calculate Pk
	Pminusa=eye(m-i+1)-2*u1*u1'/(u1'*u1);
   Pplusa=eye(m-i+1)-2*v1*v1'/(v1'*v1);
   
   %make diag(Ik, Pk)
	Pminus=eye(3);
	Pminus(i:m,i:m)=Pminusa;
	Pplus=eye(3);
   Pplus(i:m,i:m)=Pplusa;
   
   %update Q and R matrices
	Rplus(i:m,i:n)=Rplus(i:m,i:n)-2*v1*v1'/(v1'*v1)*Rplus(i:m,i:n);
   Rminus(i:m,i:n)=Rminus(i:m,i:n)-2*u1*u1'/(u1'*u1)*Rminus(i:m,i:n);
   %Rplus=max(abs(Rplus), eps);
   %Rminus=max(abs(Rminus), eps);
	Qplus=Qplus*Pplus;
   Qminus=Qminus*Pminus;
   %Qplus=max(abs(Qplus), eps);
   %Qminus=max(abs(Qminus), eps);
end
%A
%Qplus
%Rplus
%Qminus
%Rminus
%norm((Qplus'*Qplus-eye(m)),2)
%norm((Qminus'*Qminus-eye(m)),2)
