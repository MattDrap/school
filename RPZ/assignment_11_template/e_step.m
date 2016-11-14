function [Pdx,new_Pd] = e_step(X, f, b, s2, Pd, m)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  given the current esitmate of the parameters, for each image Xk,
%  esitmate the probability of the displacement of the villain's face
%  given image Xk and the prior on displacement over all images
%
%  Input parameters:
%   X, H x W x n matrix, n images that contain the villain
%   f, H x w matrix, estimate of villain's face
%   b, double, estimate of background
%   s2, double, estimate of VARIANCE of Gaussian noise
%   Pd, (W-w+1) x 1 vector, prior on displacement of face
%   m, use first m images for estimation
% 
% Output parameters:
%   Pdx, (W-w+1) x n, posterior of displacement of villain's
%              face given image Xk. This is a column stochastic
%              array.
%   new_Pd, (W-w+1) x 1 vector updated priors on displacement of
%              face in any image
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
w = size(f, 2);
H = size(X,1);
W = size(X,2);

% maximum possible displacement
dmax = W-w+1;

% preallocate space for posterior of displacements and background 

% iterate over all images
for k = 1:m
    % iterate over all possible displacements
    for d = 1:dmax
    end

    % update posteriors 
    for d = 1:dmax
    end
end

% update priors on face displacement by marginalizing images
