function out = calcError(data,a,phi)

% reconstuction error
r_err=0;
mypts=a*phi;
diff=data-mypts;
diff=diff.*diff;
diff1=diff(:);
r_err=sum(diff1);

% sparsification error
a1=a(:);
sigma=std(a1);
a1=abs(a1/sigma);
s_err=sum(a1);

out=r_err+s_err;