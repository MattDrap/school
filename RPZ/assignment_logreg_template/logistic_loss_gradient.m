function g = logistic_loss_gradient(X, y, w)
% g = logistic_loss_gradient(X, y, w)
%
%   Calculates gradient of the logistic loss function.
%
%   Parameters:
%       X - d-dimensional observations of size [d, number_of_observations]
%       y - labels of the observations of size [1, number_of_observations]
%       w - weights of size [d, 1]
%
%   Return:
%       g - resulting gradient vector of size [d, 1]
number_of_observations = size(X, 2);
pkx = 1./(1+exp(bsxfun(@times, -y,w'*X)));
pkx = 1 - pkx;
g = -1/number_of_observations * sum(bsxfun(@times, pkx.*y, X),2);
