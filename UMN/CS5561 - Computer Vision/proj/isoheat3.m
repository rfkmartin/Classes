function out=isoheat3(in,iter)

[a b]=size(in);
out=in;

for i=1:iter,
    for j=1:3,
        [inx, iny]=gradient(out(:,:,j));
        %g=1./(1+100*(inx.^2+iny.^2));
        out(:,:,j)=out(:,:,j)+50*divergence(inx,iny);
    end
end