function out=isoheat(in,iter)

[a b]=size(in);
out=in;

for i=1:iter,
    [inx, iny]=gradient(out);
    g=1./(1+100*(inx.^2+iny.^2));
    out=out+20*divergence(g.*inx,g.*iny);
end