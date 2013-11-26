function out=recon(in,template)

% RECON(IN)
%
% reconstruct an image stored as runs

[a b]=size(in);

for i=1:b,
   template(in(i).row,in(i).start:in(i).fin)=1;
end

out=template;
