function out=lo_res(in,niter)

out=in;
for i=1:niter,
    [m n]=size(in);
    clear out;
    for j=1:m/2,
        for k=1:n/2,
            out(j,k)=(in(2*(j-1)+1,2*(k-1)+1)+in(2*(j-1)+1,2*(k-1)+2)+in(2*(j-1)+2,2*(k-1)+1)+in(2*(j-1)+2,2*(k-1)+2))/4;
        end
    end
    in=round(out);
end