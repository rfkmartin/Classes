function [C, sigma] = dataset3Params(X, y, Xval, yval)
%EX6PARAMS returns your choice of C and sigma for Part 3 of the exercise
%where you select the optimal (C, sigma) learning parameters to use for SVM
%with RBF kernel
%   [C, sigma] = EX6PARAMS(X, y, Xval, yval) returns your choice of C and
%   sigma. You should complete this function to return the optimal C and
%   sigma based on a cross-validation set.
%

% You need to return the following variables correctly.
C = 1;
sigma = 0.3;

% ====================== YOUR CODE HERE ======================
% Instructions: Fill in this function to return the optimal C and sigma
%               learning parameters found using the cross validation set.
%               You can use svmPredict to predict the labels on the cross
%               validation set. For example,
%                   predictions = svmPredict(model, Xval);
%               will return the predictions on the cross validation set.
%
%  Note: You can compute the prediction error using
%        mean(double(predictions ~= yval))
%

cur_best=length(y);

for i=-2:.5:1,
   for j=-2:.5:1,
      C1=10^(i);
      sigma1=10^(j);
      model= svmTrain(X, y, C1, @(x1, x2) gaussianKernel(x1, x2, sigma1));
      y_pred = svmPredict(model,Xval);
      cur = sum(abs(yval-y_pred));
      if (cur < cur_best),
         cur_best = cur;
         C=C1;
         sigma = sigma1;
      end
   end
end


[C sigma]

% =========================================================================

end
