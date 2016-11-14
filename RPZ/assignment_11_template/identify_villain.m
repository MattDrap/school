function [optf, optd, optb, optL] = identify_villain(X,m,r,w)
% [optf, optd, optb, optL] = identify_villain(X,m,r,w)
%
% Restart EM n times. EM will be randomly initialized and may converge
% to a local maximum of the likelihood function. Store the best
% estimate of the parameters as measured by the likelihood score and
% return those estimates after EM runs n times.
%
% Input parameters:
%
%   X  H x W x N matrix, N images that contain the villain
%   m  m <= N is the number of images that should be used to esimtate
%      the face (and other unknown parameters)
%   r  the number of EM restarts to avoid local maxima.
%   w, villain's face width
%
% Output parameters:
%
%   optf the best-so-far face 
%   optd the best-so-far displacements in each image
%   optb the best-so-far  estimate of the background
%   optL the best-so-far marginal log-likelihood score

if nargin < 4
  w = 36;
end

rng(314159);
optL = -Inf;

for i = 1:r
    [f,d,b,L] = run_EM(X,m,w);
    if L(end) > optL
        optf = f;
        optd = d;
        optb = b;
        optL = L(end);
    end
end
