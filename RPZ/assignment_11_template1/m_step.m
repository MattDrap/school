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
nf = zeros(size(f));
nb = 0;
% estimate f,b
for k = 1:m
    for d = 1:dmax 
        columnsind = false(1,size(X, 2));
        columnsind(d:d+w-1) = true;
        nf = nf + Pdx(d,k).*X(:, columnsind, k);
        nb = nb + Pdx(d,k)*sum(sum(X(:, ~columnsind, k)));
    end
end
f = nf./m;
b = nb/(m*H*(W-w));

sigma = 0;
% estimate s2
for k = 1:m
    for d = 1:dmax
        columnsind = false(1,size(X, 2));
        columnsind(d:d+w-1) = true;
        
        df = sum(sum((X(:, columnsind, k) - f).^2));
        db = sum(sum((X(:, ~columnsind, k) - repmat(b, H, W-w)).^2)); 
        
        sigma = sigma + Pdx(d,k)*(df + db);
    end
end
s2 = sigma./(m*HW);
