%%% This tutorial gives illustrations of basic operations in linear
%%% algebra.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Vector operations 

% create two random vectors, and plot them
o = [0; 0]; 
x = randn(2,1)
y = randn(2,1)
subplot(1,2,1);
plotVec([x, y]);
legend('X','Y')

% Multiplying by a scalar (a) changes the length of the vector
a = 1.5
subplot(1,2,2);
h2 = plotVec(a*x,[],'ro-'); 
hold on; h1 = plotVec(x); hold off
legend([h1;h2, 'X', 'aX')

% A sum of two vectors
subplot(1,2,2); 
h1 = plotVec([x,x+y],[o,x]);
hold on;  h2 = plotVec(x+y,[],'ro-'); hold off
legend([h1;h2], 'X', 'Y (translated)', 'X+Y');

% A unit vector has a  length of 1.
% Dividing any vector by it's length will rescale it to have length 1.
% Matlab's "norm" function gives the length (Euclidean norm) of a vector.
u = randn(2,1);
u = u / norm(u);
subplot(1,2,1);
plotVec([u,x]);
legend('U', 'X');

% projection of x onto the line defined by u:
len = u' * x
proj = len * u;
subplot(1,2,2);
plotVec([u,x,proj]);
hold on; plot([x(1) proj(1)], [x(2) proj(2)], 'k--'); hold off
legend('U', 'X', '(U.X)U' ); 

% If it's hard to see what's going on in the two plots, try re-running
% the code (i.e., with a new random unit vector).

% What is the length of the projection (U.X)U) in the right-hand
% plot?  How far is x from the line (length of dashed black line) in
% the right-hand plot?

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Matrix operations: Illustration of the action of a 3x3 matrix on a
%% unit cube

clf
% this function applies a 3x3 matrix (the argument) to the vertices of
% a unit cube, and plots the resulting 3D parralelapiped (sp?):
plotCube( eye(3) );
% you can interactively rotate the cube by dragging with the mouse...

%% axis stretching:
m = [ 1.5 0   0 ; 0   1   0 ; 0   0   1];
det(m)
plotCube( m );

%% projection:
m = [ 1  0  0 ; 0  1  0 ; 0  0  0]
det(m)
plotCube( m );

%%% Rotation about X axis, 30 degrees
angle = pi*30/180;
cs = cos(angle);  sn = sin(angle);
mxr = [ 1  0   0  ; 0  cs -sn ; 0  sn  cs ]
inv(mxr)
det(mxr)
plotCube( mxr );


%%% Rotate, stretch, rotate back
myr = [cs 0 -sn ;  0 1 0 ; sn 0 cs]
mzr = [cs -sn 0 ;  sn cs 0 ; 0 0 1 ]
mys = [ 1  0  0 ; 0  0.5   0 ; 0  0  1]
m = mzr*mys*mzr'

subplot(1,3,1); plotCube( mzr' );
subplot(1,3,2); plotCube( mys*mzr' );
subplot(1,3,3); plotCube( mzr*mys*mzr' );


% Rotate, project, rotate again
mxp = [ 0  0  0 ; 0  1   0 ; 0  0  1];
myp = [ 1  0  0 ; 0  0   0 ; 0  0  1];
mzp = [ 1  0  0 ; 0  1 0 ; 0  0  0];
m = myr*mzp*mxr
det(m)
subplot(1,3,1); plotCube( mxr );
subplot(1,3,2); plotCube( mzp*mxr );
subplot(1,3,3); plotCube( myr*mzp*mxr );

% A random matrix: 
m = randn(3,3);
[U,S,V] = svd(m)
subplot(1,3,1); plotCube( V' );
subplot(1,3,2); plotCube( S*V' );
subplot(1,3,3); plotCube( U*S*V' );


