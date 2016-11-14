function [ u1, v1 ] = rdpolyfwd( u2, v2, uvn, p )
% RDPOLYFWD   RD polynomial model, primitive forward rd function
%
%   Primitive forward radial distortion function for the polynomial model.
%   Transforms x2 to x1.
%
%   [ u1, v1 ] = RDPOLYFWD( u2, v2, uvn, pars )
%       u2,v2 - 1xN each - points to be transformed, (distorted points, x2)
%       uvn - 2x1 - the no-distortion point (computed in rdundistort)
%       pars - parameters structure with following fields:
%               k - distortion coefficients
%       u1, v1 - 1xN each - transformed (undistorted, x1) points
%
%   The transformation is computed as follows:
%
%   Let
%       x2 = [ u2; v2 ] be the point to be transformed,
%       xn = [ uvn ] be the no-distortion point,
%       x1 = [ u1; v1 ] be the transformed point.
%
%   Then
%               D
%   x1 = -------------- * x2,
%         1 + sum( k )
%
%   where
%
%   D = 1 + k(1)*( ||x2||/||xn|| )^2 + k(2)*( ||x2||/||xn|| )^4 +
%         + k(3)*( ||x2||/||xn|| )^6 + ...
%
% See also: RDPOLYBCK, RDPOLYINIT, RDDIVINIT

% Copyright 2008 Ondrej Sychrovsky (sychro1@fel.cvut.cz)
% Last modified: Ondrej Sychrovsky 2009-01-17

D = rdpolygetD( [u2;v2], p.k, uvn(1)^2 + uvn(2)^2 );

K = 1 + sum( p.k(:) );

u1 = D.*u2./K;
v1 = D.*v2./K;

if nargout < 2
    u1 = [u1;v1];
end

return

