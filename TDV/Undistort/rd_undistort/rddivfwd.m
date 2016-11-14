function [ u1, v1 ] = rddivfwd( u2, v2, uvn, p )
% RDDIVFWD      RD division model, primitive forward rd function
%
%   Primitive forward radial distortion function for the division model.
%   Transforms x2 to x1.
%
%   [ u1, v1 ] = RDDIVFWD( u2, v2, uvn, pars )
%       u2,v2 - 1xN each - points to be transformed, (distorted points, x2)
%       uvn - 2x1 - the no-distortion point (computed in rdundistort)
%       pars - parameters structure with following fields:
%               lambda - distortion coefficient
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
%
%                   1 - lambda       
%   x1 = ----------------------------------- * x2
%         1 - lambda*( ||x2|| / ||xn|| )^2
%

% (c) Radim Sara (sara@cmp.felk.cvut.cz) FEE CTU Prague, 24 Aug 07
% Last modified: Ondrej Sychrovsky, 2009-01-17

n = 1 - p.lambda;
d = 1 - p.lambda.*(u2.^2 + v2.^2)./sum(uvn.^2);

u1 = n*u2./d;
v1 = n*v2./d;

if nargout < 2
    u1 = [u1;v1];
end
