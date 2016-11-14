function [E, t] = estimate_exposure(Z, w)
%ESTIMATE_EXPOSURE Estimate irradiance and exposure time
%
% [E, t] = estimate_exposure(Z, w)
%
% Estimate irradiance and exposure times from pixel intensities from multiple
% exposures.
% 
% Assume that the response function f is identity.
% (Note that if the response function is known you can transform
% the pixel intensities prior to calling this function.)
% 
% Use eps instead of zero Z values for taking the logarithm to avoid
% infinity.
%
% Input:
%   Z [NxP double] Pixel intensities,
%     Z(i,j) corresponds to the intensity of pixel i in image j.
%   w [NxP double] Weights corresponding to Z.
%
% Output:
%   E [Nx1 double] Irradiance (up to scale).
%   t [1xP double] Exposure times (up to scale),
%     t(1) = 1 (soft constraint).
%

assert(ismatrix(Z));
assert(numel(Z) == numel(w));

[N, P] = size(Z);
% Get pixel and image indices.
[i_E, i_t] = ind2sub(size(Z), (1:numel(Z))');

%% TODO: Implement me!
ind = 1:size(i_t);
b = log(Z(:));
nw = sqrt(w(:));
b = nw.*b;
EE = sparse(ind, i_E, nw);
Et = sparse(ind, i_t, nw);
A = [EE,Et];
%constraint
C = sparse(1, N+1, 1, 1, N+P);
A = [A;C];
b = [b;0];

x = A\b;
E = x(1:N);
t = x(N+1:end);
t = t';
t = exp(t);
E = exp(E);
t(1) = 1;
%E = zeros([N 1]);
%t = zeros([1 P]);

%%

assert(numel(E) == N);
assert(numel(t) == P);

end
