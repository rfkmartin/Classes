function [im]=zeroB(im,num)

if ~exist('num')
  num=10;
end

im(:,1:num,:)=0;im(1:num,:)=0;
im(:,end-num+1:end,:)=0;im(end-num+1:end,:,:)=0;