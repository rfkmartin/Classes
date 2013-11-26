
function out = compEigV(diffData)


eigVal = eig(diffData'*diffData);
[eigVprime, eigValprime] = eig(diffData'*diffData);

for i = 1:13 %arbitrarily chosen
	eigV(:,i) = (1/sqrt(eigVal(i))) * diffData * eigVprime(:,i);
end;

% Sort in decending order

for i = 1:13,
	j = 13; 
   while (j > i)

      if (eigVal(j - 1) < eigVal(j))
         temp = eigVal(j);
         eigVal(j) = eigVal(j - 1);
         eigVal(j - 1) = temp;
         temp2 = eigV(:,j);
         eigV(:,j) = eigV(:,j-1);
         eigV(:,j-1) = temp2;
      end; % end if
      j = j - 1;
    end; %end while
  end; %end for
 
  % Now select top 

  for i = 1:13,
    out(:,i) = eigV(:,i);
  end; 
