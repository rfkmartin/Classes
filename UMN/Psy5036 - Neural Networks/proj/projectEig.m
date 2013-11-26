

function out = projectEig(image, avg, eigV)

  for i = 1:min(size(eigV)),
    out(i) = eigV(:,i)' * reshape((image - avg)', 240*320*4, 1);
  end;
 
