function [f,d,b,L] = run_EM(X,m,w)
% [f,d,b,L] = run_EM(X,m,w)
%
% 
% Runs EM loop until the likelihood of observing X given current
% estimate of parameters is idempotent as defined by a fixed tolerance
%
% Input parameters:
%   X, H x W x N matrix, N images containing the villain's face
%   m, use first m of N total images in X for estimation
%   w, villain's face width
%
% Output parameters:
%   f, estimate of the image of the face
%   d, estimate of the displacements of the face for each image
%   b, estimate of the background
%   L, 1 x iter+2 matrix, the marginal log-likelihoods of observing
%   image set X at initial guess, after each EM iteration, and after
%   final estimate of posteriors
%
%
if nargin < 3
  w = 36;
end
H = size(X,1);
W = size(X,2);

% maximum possible displacement
dmax = W-w+1;

% set stopping criterion (DO NOT CHANGE)
tolerance = 0.001;
max_iters = 20;
iter = 1;

% randomize EM starting point of inferred parameters using FIXED
% seed
f = rand(H,w)*256;
b = rand(1,1)*256;
s2 = rand(1,1)*64^2;

% randomly generate prior on displacements using FIXED seed
Pd = rand(dmax,1);
Pd = Pd/sum(Pd);
d = [];

% compute initial marginal log-likelihood of observing X given current
% parameters
L = calc_mllh(X,f,b,s2,Pd,m);

% EM loop
while 1
    % E-step
    [Pdx, Pd] = e_step(X, f, b, s2, Pd, m);
    % M-step        
    [f,b,s2] = m_step(X, f, b, s2, Pdx, m);
    % compute marginal log-likelihood of observing X given current
    % parameters
    mllh = calc_mllh(X,f,b,s2,Pd,m);
    L = [L, mllh];
    % check to see if marginal log-likelihood is idempotent or stop
    % after max_iters
    if iter == max_iters || L(iter) == mllh
        break;
    end
    iter = iter+1;
end

% make final estimate of posteriors
Pd = 1/m*sum(Pdx,2);
% compute final marginal log-likelihood
mllh = calc_mllh(X,f,b,s2,Pd,m);
L = [L, mllh];
% find the displacement of the face in each image withy maximum a
% posteriori (MAP) estimate
[val, ind] = max(Pdx + repmat(Pd, 1, size(Pdx, 2)));
d = ind;
