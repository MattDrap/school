function [f,b,s2] = m_step(X,f,b,s2,Pdx,m)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%  maximizes f,b,s2 given esitmate of posteriors defined by Pdx
%
% Input parameters:
%   X, H x W x n matrix, m images that contain the villain
%   f, H x w matrix, estimate of villain's face
%   b, double, estimate of background
%   s2, double, estimate of standard deviation of noise
%   Pdx, W-w+1 x n matrix, posterior of displacement of villain's
%   m,  use first m images for estimation
%
% Output parameters:
%   f, H x w matrix, estimate of villain's face
%   b, double, estimate of background color
%   s2, double, estimate of the VARIANCE of noise
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
w = size(f, 2);
H = size(X,1);
W = size(X,2);

% maximum possible displacement
dmax = W-w+1;
HW = H* W;

% estimate f,b
for k = 1:m
    for d = 1:dmax
    end
end

% estimate s2
for k = 1:m
    for d = 1:dmax
    end
end
