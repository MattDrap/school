function y = classify_images(X, w)
% y = classify_images(X, w)
%
%   Classification by logistic regression.
%
%   Parameters:
%       X - d-dimensional observations of size [d, number_of_observations]
%       w - weights of size [d, 1]
%
%   Return:
%       y - estimated labels of the observations of size [1, number_of_observations]
pkx = 1./(1+exp(w'*X));
y = ones(1, size(X, 2));
y(pkx >=  0.5) = -1;