function [E, finv] = estimate_response(Z, t, w, lambda)
%ESTIMATE_EXPOSURE Estimate irradiance and response function
%
% [E, finv] = estimate_exposure(Z, t, w, lambda)
%
% Estimate irradiance and the inverse response function from pixel intensities
% from multiple exposures.
%
% Input:
%   Z [NxP double] Pixel intensities.
%     Z(i,j) is the intensity of pixel i in image j.
%   t [1xP double] Exposure times, t > 0.
%   w [NxP double] Weights.
%   lambda [1x1 double] Smoothness violation penalty.
%
% Output:
%   E    [Nx1 double] Irradiance (up to scale).
%   finv [Lx1 double] Inverse response function (up to scale),
%     finv(round(L/2)) = 1 (soft constraint).
%

assert(ismatrix(Z));
assert(numel(Z) == numel(w));
assert(size(Z, 2) == numel(t));
assert(all(t(:) > 0));

[N, P] = size(Z);
L = max(Z(:)) + 1;
% Get pixel and image indices.
[i_E, i_t] = ind2sub(size(Z), (1:numel(Z))');

%% TODO: Implement me!
ind = 1:size(i_t);
b = t(i_t);
b = log(b(:));
nw = sqrt(w(:));
nw = nw(:);
b = b.*nw;
EE = sparse(ind, i_E, -nw);
G = sparse(ind, Z(:)+1, nw);
A = [G, EE];
%smooth
sind = 1:L-2;
S1 = sparse(sind, sind , sqrt(lambda), L-1, N+L);
S2 = sparse(sind, sind+1 , sqrt(lambda) * -2, L-1, N+L);
S3 = sparse(sind, sind+2, sqrt(lambda), L-1, N+L);
S = S1 + S2 + S3;

A = [A;S];
b = [b;zeros(L-1,1)];
%endsmooth
%constraint
C = sparse(1, round((L+1)/2), 1, 1, N+L);
A = [A;C];
b = [b;0];

x = A\b;
finv = x(1:L);
E = x(L+1:end);
finv = exp(finv);
E = exp(E);
%E = zeros([N 1]);
%finv = zeros([L 1]);

%%

assert(numel(finv) == L);
assert(numel(E) == N);

end
