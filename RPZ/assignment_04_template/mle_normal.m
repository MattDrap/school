function [mu, sigma] = mle_normal(x)
% [mu sigma] = mle_normal(x)
%
%   Computes maximum likelihood estimate of mean and sigma of a normal
%   distribution.
%
%   Parameters:
%       x - input features <1 x n>
%
%   Returns:
%       mu - mean
%       sigma - standard deviation
n = length(x);
mu = 1/n * sum(x); %1/n * sum(x)
sigma = sqrt(1/n*sum((x - mu).^2));
