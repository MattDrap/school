function [ u2, v2 ] = rddivbck( u1, v1, uvn, p )
% RDDIVBCK      RD division model, primitive backward rd function
%
%   Primitive backward radial distortion function for the division model.
%   Transforms x1 to x2.
%
%   [ u2, v2 ] = RDDIVBCK( u1, v1, uvn, pars )
%       u1,v1 - 1xN each - points to be transformed (undistorted points, x1)
%       uvn - 2x1 - the no-distortion point (computed in rdundistort)
%       pars - parameters structure with the following fields:
%               lambda - distortion coefficient
%       u2,v2 - 1xN each - transformed (distorted, x2) points
%
%   The transformation is computed as follows:
%
%   Let
%       x1 = [ u1; v1 ] be the point to be transformed,
%       xn = [ uvn ] be the no-distortion point,
%       x2 = [ u2; v2 ] be the transformed point.
%
%   Then
%
%                            xh
%   x2 = ----------------------------------------------,  
%         1 + sqrt( 1 + lambda * ||xh||^2 / ||xn||^2 )
%       
%   where
%           2 * x1
%   xh = ------------.
%         1 - lambda
%

% (c) Radim Sara (sara@cmp.felk.cvut.cz) FEE CTU Prague, 24 Aug 07
% Last modified: Ondrej Sychrovsky, 2009-01-17

xn2 = sum( uvn.^2 );

u2 = 2*u1./( 1-p.lambda );
v2 = 2*v1./( 1-p.lambda );

d = 1 + sqrt( 1 + p.lambda*( u2.^2 + v2.^2 )/xn2 );

u2 = u2./d;
v2 = v2./d;

if nargout < 2
    u2 = [u2;v2];
end
