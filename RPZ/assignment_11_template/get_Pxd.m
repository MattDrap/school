function Pxd = get_Pxd(X, f, b, s2, d)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Estimate the log-likelihood that image X was observed given that the villain's
% face is at displacement d.
%
% Input parameters:
%
%   X      ... H x W, an image that contains the villain
%   f      ... H x w matrix, estimate of villain's face
%   b      ... 1 x 1 double, estimate of background
%   s2     ... 1 x 1 s2, estimate of VARIANCE of Gaussian noise
%   d      ... displacement of villain's face relative to left side
%              of the image X
%
% Output parameters:
%   
%   Pxd    ... log-likelihood of observing image X given that the
%              villain's face F is located at displacement d
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

w = size(f,2);
H = size(X,1);
W = size(X,2);
dmax = W-w+1;