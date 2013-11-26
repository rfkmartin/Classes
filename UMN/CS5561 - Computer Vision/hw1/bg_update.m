function [out, mask] = bg_update(bg,cur_frame)

% BG_UPDATE(BG,CURRENT)
%
% updates a background based on Koller, et al.
%
% bg(t+1)=bg(t)+(alpha1*(1-M(t))+alpha2*M(t))*D(t)
%
% where M(t) is the motion mask at time t and D(t)
% is the absolute difference between the bg and the
% current frame. alpha1 and alpha2 should update
% themselves to handle backgrounds changing at
% different rates.

% Gaussian kernel
g=[1 2 1;
   2 4 2;
   1 2 1];

% Gaussian horizontal
hor=[-2 -2 -2;
   0 0 0;
   2 2 2];

% Gaussian vertical
ver=[-2 0 2;
   -2 0 2;
   -2 0 2];

% Get difference of background and current
diff=cur_frame-bg;
diff_norm=normal(diff,0,255);
figure(4);image(diff_norm);

% Apply filters to background and difference, and then normalize
diff_g=normal(filter2(g,diff_norm),0,255);
figure(2);imhist(normal(diff_g,0,1));
%bg_g=normal(filter2(g,bg),0,255);
diff_hor=normal(filter2(hor,diff_norm),0,255);
figure(5);imhist(normal(diff_hor,0,1));
%bg_hor=normal(filter2(hor,bg),0,255);
diff_ver=normal(filter2(ver,diff_norm),0,255);
figure(6);imhist(normal(diff_ver,0,1));
%bg_ver=normal(filter2(ver,bg),0,255);

% Threshold at arbitrary level
% Eventually the threshold should be selected
% automatically. Until then, this will do.
diff_g_t=diff_g>96;
diff_hor_t=diff_hor>192;
diff_ver_t=diff_ver>160;

% OR binary masks together
mask=or(diff_g_t,or(diff_hor_t,diff_ver_t));
figure(4);imshow(mask)

% Compute bg(t+1)
alpha1=0.1; alpha2=.9;
mac=alpha2*mask;
mac1=alpha1*mask;
%figure(5);imshow(mac.*diff)
%out=bg.*not(mask)+alpha1*diff.*mask+alpha2*bg.*mask;
out=bg.*not(mask)+alpha2*bg.*mask+alpha1*diff.*mask;
mean(mean(out))
%out=normal(out,0,255);
%figure(2);image(normal(cur_frame-out,0,255))
