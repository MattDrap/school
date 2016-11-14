function mllh = calc_mllh(X,f,b,s2,Pd,m)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% calculates the marginal log-likelihood of observing image set
% X
%
% INPUT
%   X      H x W x N matrix, N images that contain the villain
%   f      H x w matrix, estimate of villain's face
%   b      1 x 1 double, estimate of background
%   s2     1 x 1 s2, estimate of VARIANCE of noise
%   Pd     priors on displacement of face in any image
%   m      use first m images for estimation
%
% OUTPUT
%  mllh     marginal log-likelihood
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
N = size(X,3);
W = size(X,2);
w = size(f,2);
dmax = W-w+1;

% joint likelihood of x,d
pjxd = zeros(m,dmax);

for k = 1:m
    for d = 1:dmax
        pjxd(k,d) = get_Pxd(X(:,:,k),f,b,s2,d)+log(Pd(d));
    end
end

mllh = sum(logsumexp(pjxd));

function s = logsumexp(x)
y = max(x,[],2);
x = bsxfun(@minus,x,y);
s = y+log(sum(exp(x),2));
ind = find(~isfinite(y));
if ~isempty(ind)
    s(ind) = y(ind);
end