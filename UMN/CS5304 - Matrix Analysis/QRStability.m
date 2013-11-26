% Matlab code QRStability.m
% For "Applied Numerical Linear Algebra",  Question 3.2
% Written by James Demmel, Aug 2, 1996;
%                Modified, Jun 2, 1997
%
% Compare the numerical stability of 3 algorithms for computing
% the QR decomposition: 
%   QR using Householder transformations
%   CGS (Classical Gram-Schmidt)
%   MGS (Modified Gram-Schmidt)
%
% Inputs:
%
%   m, n = numbers of rows, columns in test matrices
%          m should be at least n
%   samples = number of test matrices to generate
%             samples should be at least 1
%   cnd = condition number of test matrices to generate
%         (ratio of largest to smallest singular value)
%         cnd should be at least 1
%
% Outputs:
%
%   For each algorithm, the maximum value of the residual
%   norm(A-Q*R)/norm(A), which should be around 
%   macheps = 1e-16 for a stable algorithm
%
%   For each algorithm, a plot (versus sample number)
%   of the orthogonality norm(Q'*Q-I), which should 
%   also be around macheps if the computed Q is orthogonal
%   and the algorithm is stable
%
residual = [];
orth = [];
normH=0;
normC=0;
normM=0;
% Generate samples random matrices
for cnder = 1:15,
   cnd=10^cnder
for exnum = 1:samples,
% Generate random matrix A, starting with the SVD of a random matrix
  A=randn(m,n);
  [u,s,v]=svd(A);
% Let singular values range from 1 to cnd, with
% uniformly distributed logarithms
  sd = [1, cnd, exp(rand(1,n-2)*log(cnd))];
  s = diag(sd);
  A=u(:,1:n)*s*v';
% Perform CGS (A = Qcgs*Rcgs) and MGS (A = Qmgs*Rmgs)
  Rcgs=[]; Rmgs=[];
  Qcgs=[]; Qmgs=[];
  for i=1:n,
    Qcgs(:,i)=A(:,i);
    Qmgs(:,i)=A(:,i);
    for j=1:i-1,
      Rcgs(j,i) = (Qcgs(:,j))'*A(:,i);
      Qcgs(:,i) = Qcgs(:,i) - Rcgs(j,i)*Qcgs(:,j);
      Rmgs(j,i) = (Qmgs(:,j))'*Qmgs(:,i);
      Qmgs(:,i) = Qmgs(:,i) - Rmgs(j,i)*Qmgs(:,j);
    end
    Rcgs(i,i) = norm(Qcgs(:,i));
    Rmgs(i,i) = norm(Qmgs(:,i));
    Qcgs(:,i) = Qcgs(:,i) / Rcgs(i,i);
    Qmgs(:,i) = Qmgs(:,i) / Rmgs(i,i);
  end
% Perform Householder QR
  [Qhouse,Rhouse]=qr(A,0);
% Compute residuals for each algorithm (cnd = norm(A))
  residual(exnum,1:3) = ...
     [ norm(A-Qhouse*Rhouse), norm(A-Qcgs*Rcgs), norm(A-Qmgs*Rmgs) ]/cnd;
% Compute orthogonality of Q for each algorithm 
ee = eye(n);
normH=normH + (norm(Qhouse'*Qhouse-ee));
normC=normC + (norm(Qcgs'*Qcgs-ee));
normM=normM + (norm(Qmgs'*Qmgs-ee));
orth(exnum,1:3) = ...
     [ norm(Qhouse'*Qhouse-ee), norm(Qcgs'*Qcgs-ee), norm(Qmgs'*Qmgs-ee) ];
end
result(cnder,1:3)=[normH/samples, normC/samples, normM/samples];
end
% Limit orth to 1 (any larger error is as bad) so it shows up on plot
orth = min(orth,ones(size(orth)));
% Print max residuals
disp(['max( norm(A-Q*R)/norm(A) ) for Householder QR = ', ...
       num2str(max(residual(:,1)))])
disp(['max( norm(A-Q*R)/norm(A) ) for CGS            = ', ...
       num2str(max(residual(:,2)))])
disp(['max( norm(A-Q*R)/norm(A) ) for MGS            = ', ...
       num2str(max(residual(:,3)))])
% Plot orthogonalities
clf
% make sure orthogonalities are at least eps to avoid log(0)
result = max(result,eps);
semilogy((1:cnder),result(:,1),'b*', ...
         (1:cnder),result(:,2),'r*', ...
         (1:cnder),result(:,3),'g*')
axis([1 cnder 1e-16 100])
grid
ylabel('orthogonality')
xlabel(['test condition number'])
title('Orthogonality of Q for CGS (red), MGS (green), Householder (blue)')
