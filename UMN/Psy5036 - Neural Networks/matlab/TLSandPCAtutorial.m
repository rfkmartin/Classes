%% ---------------------------------------------------------------------
%% SVD and Eigenvector techniques for fitting and discriminating data:
%%   Total-Least-Squares Regression, Principal Components Analysis, and
%%   Fisher's Linear Discriminant
%% ---------------------------------------------------------------------

%% Total Least Squares Regression:
%% In classical least-squares regression, errors are defined as the
%% squared vertical distance to the fitted line (or other function).
%% But if there is not a clear assignment of "dependent" and
%% "independent variables, then it may make sense to measure errors as
%% the squared PERPENDICULAR distance to the fitted line.

%% For a line (plane/hyperplane) perpendicular to the unit vector u,
%% that passes within distance u0 from the origin, the error is
%% expressed as:
%%  (data * u - u0)^2

% For simplicity, consider data that live in a 2D space [X, Y], and
% fit with a line through the origin (e.g., u0 = 0).  Create data that
% has uncertainty both in X and Y directions:
X = [-1:0.05:1]';
Y = 2*X;
X = X + 0.25*randn(size(X));
Y = Y + 0.25*randn(size(Y));
figure(1); clf
h0 = plot(X, Y, 'o');
axis('equal');

% Now we plot the sqrt of the average squared length of the data as
% projected onto vectors around the unit circle.  That is, for each
% unit vector u, we want to plot a vector: 
%   sqrt( sum_n (data_n * u)^2/N ) * u 
% where data = [X,Y].
angles = 2*pi*[0:64]/64;
uVectors = [cos(angles); sin(angles)];  % each col is a unit vector
lengths = sqrt(mean( ([X,Y] * uVectors).^2 ))
hold on;
hu = plot(lengths.*uVectors(1,:), lengths.*uVectors(2,:), 'b');
hold off;
% Note that this is not an ellipse (it's not the same as plotting 
%    the action of a matrix on a vector...)

% Solution for u is the minimal-singular-value vector of the data.
% Matlab svd command arranges singular-values from maximal to minimal.

data = [X,Y];
[U,S,V]=svd(data);

diag(S)

% V(:,2) is the vector corresponding to the min singular value
% It is the unit vector perpendicular to the best fit line
v2 = V(:,2)                      
norm(v2)
hold on
h2 = plotVec(v2,[0 0]','r');                      %unit vector
hold off

% V(:,1) is the vector corresponding to the 2nd smallest singular
% value (or in this case the maximal singular value).
% It is perpendicular to v2, and as such is the unit vector
% in the direction of the best fit line.
v1=V(:,1);
norm(v1)
hold on
h1 = plotVec(v1, [0 0]', 'g');


legend([h0,hu,h2,h1], ...
'data', ...
'sqrt of sum of squared components along unit vectors', ...
'unit vec with min singular value (perp to line fit)', ...
'unit vec with max singular value (direction of line fit)', 2)

% As expected, v1 and v2 are orthogonal
v2'*v1

% The slope of the best fit line is
v1(2)/v1(1)

% which should be close to the value we used to create the data (2).
% We can also obtain the slope from v2, which is orthogonal to the
% best fit line.  
-v2(1)/v2(2)

% We can also plot the data projected onto v1:
% project_v1 = (data*v1) * v1'

figure(2); clf
plot(X, Y, 'o');
axis('equal')
project_v1 = (data*v1) * v1';                
hold on
plot(project_v1(:,1), project_v1(:,2), 'ro')              
hold off
legend('original data', 'data projected onto v1', 2);

%% add orthogonal displacements
hold on
plot([X, project_v1(:,1)]', [Y project_v1(:,2)]', 'k');
hold off

%% The error in our fit
sqr_err = sum((data*v2).^2)

%% How does this error compare to what you would get from ordinary
%% least squares regression?


%% ----------------------------------------
%% Line that does not pass through origin

X = [1:.2:10]';
Y = 2*X + 5;
X = X + 0.2*randn(size(X));
Y = Y + 0.2*randn(size(Y));
figure(2); clf;
plot(X, Y, 'o')
axis('equal');

%% First subtract mean from the data.

mean_X = mean(X) 
mean_Y = mean(Y)
mn = [mean_X; mean_Y];

%% Now find vectors in V corresponding to smallest and largest 
%% singular values:

data = [X' - mean_X; Y' - mean_Y]';
[U,S,V] = svd(data);

% Lets plot the new data on a separate graph 
% (remember we subtracted the mean)

figure(3)
clf
h0=plot(data(:,1), data(:,2), 'o')
axis('equal')

% V(:,2) is the vector corresponding to the min singular value
% It is the unit vector perpendicular to the best fit line.
v2 = V(:,2)
hold on
h2=plotVec(v2, [0 0]', 'r');
hold off

% V(:,1) is the vector corresponding to the max singular value
% It is the unit vector best fit line.
v1=V(:,1);
hold on
h1=plotVec(v1, [0 0]', 'b');
hold off

%% Note these unit vectors pass through the origin

legend([h0, h2,h1], ...
    'data - mean(data)', ...
   'perpendicular vector through origin', ...
   'vector in direction of line fit to data through origin', 2)

%% The error in our fit 
%% (note distance from origin is 0, since we subtracted the mean)
sqr_err = sum( (data*v2).^2 )

%% Now lets look at the original data....

figure(2)
hold on
% add mean back
plotVec(v1+mn, mn, 'k')
plotVec(v2+mn, mn, 'r')
hold off

legend('data', ...
    'vector perpendicular to line fit to data', ...
    'vector in direction of line fit to data', 2)

% The equation of the line fit: Y = a*X + b

a = V(2)/V(1)

% Y - mean_Y = a * (X - mean_X)
% Y = a*X - a*mean_X + mean_Y

b = - a*mean_X + mean_Y

% Note these are quite close to the a and b in the data we created...
% Y = 2*X + 5; (plus noise)

%% =================================================================
%% Principal Component Analysis

% Often, one has a data set in some large-dimensional space, but the
% actual data are close to lying within a much smaller-dimensional
% subspace.  In such cases, one would like to project the data into
% the small-dimensional space in order to summarize or analyze it.
% Specifically, the least squares formulation of the problem is: find
% a subspace that captures most of the summed squared vector lengths
% of the data.  This problem is just a variant of the TLS problem
% discussed above.  The axes (basis) for this low-dimensional space
% are known as the "Principal Components" of the data, and correspond
% to the columns of V (the second orthogonal matrix in the SVD)
% associated with the largest singular values.

figure(1); clf;
load 'TLS2'
X
Y
Z
plot3(X,Y,Z, 'b .', 'MarkerSize', 20)
axis([-10 10 -10 10 -10 10]);
set(gca,'XGrid','on','YGrid','on','ZGrid','on')
rotate3d on

len1 = size(X,1)
len2 = size(X,2)
X = reshape(X, len1*len2, 1);
Y = reshape(Y, len1*len2, 1);
Z = reshape(Z, len1*len2, 1);
data = [X,Y,Z];
[U,S,V] = svd(data);

diag(S)

% The third sigular value is much smaller than the first and second
% but not zero. We will describe the data as a plane in 3d space,
% perpendicular to V(:,3) 

% Plot u perpendicular to the plane fit.
% u is the vector in V corresponding to minimal (or in this case third)
% singular value.

u = V(:,3);
hold on
plot3([0 0 u(1)], [0 0 u(2)], [0 0 u(3)], 'k', 'LineWidth', 2)  
hold off

% The other two vectors in V define the plane fit perpendicular to u...
v1 = V(:,1);              % vector corresponding to first singular val
v2 = V(:,2);              % vector corresponding to second singular val

hold on
plot3([0 0 v1(1)], [0 0 v1(2)], [0 0 v1(3)], 'r', 'LineWidth', 2)  
plot3([0 0 v2(1)], [0 0 v2(2)], [0 0 v2(3)], 'r', 'LineWidth', 2)
hold off

% Plot fitted plane and errors

figure(2)
clf;
plot3(X,Y,Z, 'b .', 'MarkerSize', 20)
set(gca,'XGrid','on','YGrid','on','ZGrid','on')

% projection of data onto plane
project1 = (data*v1) * v1'
project2 = (data*v2) * v2'
plane_project = project1+project2;

hold on
c = ones(len1, len2);
mesh(reshape(plane_project(:,1),len1,len2), ...
reshape(plane_project(:,2),len1,len2), ...
reshape(plane_project(:,3),len1,len2), c);
colormap('gray');
hold off
hidden off

hold on
plot3([X, plane_project(:,1)]', [Y plane_project(:,2)]', ...
[Z, plane_project(:,3)]', 'r')
hold off

rotate3d on

%% ----------------------------------------
%% Another example: 3D data along a line.
figure(2);
clf
load 'TLS3'
plot3(X,Y,Z, 'b .', 'MarkerSize', 5)
axis([-8 8 -8 8 -8 8])
set(gca,'XGrid','on','YGrid','on','ZGrid','on')
rotate3d on;
% The data appear close to a line in 3d space.

len1 = size(X,1)
len2= size(X,2)
X = reshape(X, len1*len2, 1);
Y = reshape(Y, len1*len2, 1);
Z = reshape(Z, len1*len2, 1);
data = [X,Y,Z];
[U,S,V] = svd(data);

diag(S)

% Note second and third singular values are quite small in comparison
% to first singular value. We will describe the data as a line in
% 3d space, perpendicular to V(:,2:3).

% Plot u = [u1, u2]  perpendicular to the line fit.
% u1 and u2 are vectors in V corresponding to third and second
% singular values.

u1 = V(:,3);
hold on
plot3([0 0 u1(1)], [0 0 u1(2)], [0 0 u1(3)], 'k', 'LineWidth', 3)
hold off

u2 = V(:,2);
hold on
plot3([0 0 u2(1)], [0 0 u2(2)], [0 0 u2(3)], 'k', 'LineWidth', 3)
hold off

% Plot the other vector corresponding to first singular value
% This describes our line fit to the data.
v = V(:,1);                    

hold on
plot3([0 0 v(1)], [0 0 v(2)], [0 0 v(3)], 'r', 'LineWidth', 4)  
hold off

% Note the red vector corresponding to the first (maximal) 
% singular value describes the line fit through the data.
% And that the other 2 vectors corresponding to the second
% and third singular value together define the plane perpendicular
% to this line.

%% =================================================================
%% Re-statement in terms of  eigenvectors

%% The "eigenvectors" of a square matrix are a set of vectors that
%% the matrix simply re-scales:
%%   S * v = e * v.
%% The scalar e is known as the "eigenvalue" associated with v.

%% The problems we've been considering can be restated in terms of
%% eigenvectors by noting a simple relationship between svd and 
%% eigenvector decompositions.  The total least  squares problems all 
%% involve minimizing expressions
%%    |M * v|^2 = v' * M' * M * v
%% Substituting the svd  (M = U*S*V') gives:
%%    v'*V*S'*U'*U*S*V'*v  =  v'*(V*S'*S*V'*v)
%% Consider the parenthesized expression, and note that when v = v_n, 
%% the nth column of V, then this expression becomes:
%%    (V*S'*S*V'*v_n) = (V * s_n^2 * e_n) = s_n^2 * v_n
%% That is,  v_n is an eigenvector of M'*M, with associated eigenvalue
%%   e_n = s_n^2.
%% Furthermore, given a complete set of orthonormal eigenvectors in a 
%% matrix E, we get a decomposition of M'*M:
%%    (M'*M)*E = E*D  =>  (M'*M) = E*D*E'
%% where D is a diagonal matrix of the eigenvalues, e_n = s_n^2.

%% Thus, we can solve total least squares problems by seeking the
%% eigenvectors of M'*M, which can be computed via Matlab's "eig"
%% function.

%% Here's an example:
figure(1);
clf
ax = [-1 4]';
Npts = 140;
data = randn(Npts,1)*ax';
data = data + [.1*randn(Npts,1) 1*randn(Npts,1)];
plot(data(:,1), data(:,2),'o')
axis('equal');

% Compute the eigenvectors, using our "sortedEig" function (matlab's
% "eig" function does not give the eigenvalues in any particular
% order).  
[V, D] = sortedEig(data'*data)

% The eigenvector corresponding to the largest eigenvalue is called
% the first principal component. The eigenvector gives the direction
% and the eigenvalue gives the sum of squared lengths of projections
% of the data onto that eigenvector.  Similarly, the eigenvector
% corresponding to the second largest eigenvalue is called the second
% principal component. Note that in our example it is much smaller
% than the first and captures much less of the data.

% Plot the first and second principle components
% We'll plot them at 3 times the standard deviation of the data.
u = V(:,2)
hold on
v=V(:,1);
sd = 3*sqrt(diag(D) / (length(data)-1) );
plot([ 0 v(1)*sd(1)], [0 v(2)*sd(1)], 'r')       
plot([ 0 -v(1)*sd(1)], [0 -v(2)*sd(1)], 'r')     
plot([ 0 u(1)*sd(2)], [0 u(2)*sd(2)], 'r')      
plot([ 0 -u(1)*sd(2)], [0 -u(2)*sd(2)], 'r')      
hold off

% Now compare the vectors in V with those we get from SVD:
[U,S,V2] = svd(data);

V2
V

%% =================================================================
%% Linear Discriminants

%% Suppose the data points are labeled, with one of two labels.  You
%% want to find a line that best separates the two classes of data.
%% This problem may be formulated as a Rayleigh Quotient minimization,
%% which can be solved as a generalized eigenvector problem.

%% Generate fake data:
% pick an axis
ax = randn(2,1);
ax = ax./norm(ax);
perp = [ax(2); -ax(1)];

Npts = 140;
mn1 = [0; 0];
data1 = ones(Npts,1)*mn1' + (randn(Npts,1)*ax' + 0.25*randn(Npts,1)*perp');
mn2 = mn1 + 2*ax + 0.7*perp;
data2 = ones(Npts,1)*mn2' + (randn(Npts,1)*ax' + 0.25*randn(Npts,1)*perp');

%% Plot the data
figure(1); clf
plot(data1(:,1), data1(:,2), 'ro', data2(:,1), data2(:,2), 'bo');
legend('data set 1', 'data set 2');
axis('equal');

%% Fisher's Linear Discriminant is the projection vector with the ...
%%    maximimum ratio of between-class to within-class scatter:
%%
%%             u' * diff' * diff * u
%% max  --------------------------------------
%%      u' * (zdata1'*zdata1 + zdata2'*zdata2) * u
%%
%%  where zdataN = dataN - mean(dataN),
%%  and diff =  mean(data1)-mean(data2)

zdata1 = data1 - ones(Npts,1)*mean(data1);
zdata2 = data2 - ones(Npts,1)*mean(data2);

diff = mean(data1)-mean(data2)

%% We can solve this problem by transforming the coordinate system
%% so that the denominator is just the square of the optimization vector:
[V,D] = eig(zdata1'*zdata1 + zdata2'*zdata2);

%% Now (zdata1'*zdata1 + zdata2'*zdata2) = V*D*V'
%% If we define
ixform = sqrt(D)*V';
xform = V * inv(sqrt(D));
%% Note that substituting u = xform*v (v = ixform*u) in the denominator gives:
%%  v' * xform' * (zdata1'*zdata1 + zdata2'*zdata2) * xform * v
%%     = v' * xform' * V*D*V' * xform * v
%%     = v' * v
%%  Verify that this is in fact equal to the identity:
xform'*(zdata1' *zdata1 + zdata2' *zdata2)*xform

%% The solution for v will be sought in the transformed data space. 
%% We can plot the transformed data:
figure(2); clf
tdata1 = data1*xform;  tdata2 = data2*xform;
plot(tdata1(:,1), tdata1(:,2), 'ro', ...
    tdata2(:,1), tdata2(:,2), 'bo'); hold off
legend('transformed data set1', 'transformed data set2');
axis('equal')

%% Of course, the transformation also modifies the numerator.  THe full  
%% optimization problem is now:
%%
%%     v' * (xform' * diff' * diff * xform) * v
%% max --------------------------------------
%%                      v' * v
%%
%% which is a standard TLS/PCA problem

[V,D] = sortedEig(xform' * diff' * diff * xform);
v = V(:,1); 				% The maximal-eigenvalue eigenvector 

hold; plot([0 0.5*v(1)], [0 0.5*v(2)], 'k'); hold off

%% transform the solution back into the original space, to get the
%% discriminating unit vector.
u = xform * v; u = u/norm(u)

figure(1);
hold on; plot([0 u(1)], [0 u(2)], 'k'); hold off

%% Now u is a vector perpendicular to the optimal dividing line 
%% (plane/hyperplane).  Where should the dividing line fall?
%% In this specific problem, where the two data clouds are ...
%% distributed in the same manner, the solution is a line that falls 
%% midway between the  means of the two data sets:
mn = mean([data1*u; data2*u])
uPerp = [u(2); -u(1)];
%% The discriminant line is parameterized by scalar a in the expression:
%%    a*uPerp + u*mn, 
%% we plot a line from a=-2 to a=2:
hold on; 
plot(uPerp(1)*[-2,2]+u(1)*mn, uPerp(2)*[-2,2]+u(2)*mn, 'k');
hold off;

%% Plot a histogram of the data, projected onto the discriminant:
[H1,X1] = histo(data1*u, Npts/5, 0);
binsize = (X1(2)-X1(1));
[H2,X2] = histo(data2*u, -binsize, binsize/2);
figure(3); clf
bar(X1, H1, 0.5, 'r');
hold on; bar(X2, H2, 0.5, 'b'); hold off


