function [L maximizerSigma maxL] = loglikelihood_sigma(x, D, sigmas)
% [L maximizerSigma maxL] = loglikelihood_sigma(x, D, sigmas)
%
%   Compute log ligelihoods and maximum ll of a normal
%   distribution with fixed mean and variable standard deviation.
%
%   Parameters:
%       x - input features <1 x n>
%       D - D.Mean the normal distribution mean
%       sigmas - <1 x m> vector of standard deviations
%
%   Returns:
%       L - <1 x m> vector of log likelihoods
%       maximizerSigma - sigma for the maximal log likelihood
%       maxL - maximal log likelihood
  
% no need of for loops!!!
N = length(x);
inner_sum = sum((x - D.Mean).^2);
log_sqrt2pi = N*log(1/sqrt(2*pi));
sigmas_mult = 1./(2*sigmas.^2);
L = -N*log(sigmas)+log_sqrt2pi-sigmas_mult*inner_sum; 

maximizerSigma = fminbnd(@(sig) N*log(sig)-log_sqrt2pi+1/(2*sig^2)*inner_sum, sigmas(1), sigmas(end)); 
maxL = -N*log(maximizerSigma)+log_sqrt2pi-1/(2*maximizerSigma^2)*inner_sum;
