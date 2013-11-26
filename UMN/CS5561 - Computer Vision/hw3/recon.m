function out=recon(in)

% RECON(IN)
%
% reconstruct an image stored as runs

[a b]=size(in);
out=zeros(240,320);

for i=1:b,
   out(in(i).row,in(i).start:in(i).fin)=1;
end

