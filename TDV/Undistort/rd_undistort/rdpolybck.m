function [ u2, v2 ] = rdpolybck( u1, v1, uvn, p )
% RDPOLYBCK     RD polynomial model, primitive backward rd function
%
%   Primitive backward radial distortion function for the polynimial model.
%   Transforms x1 to x2.
%
%   [ u2, v2 ] = RDPOLYBCK( u1, v1, uvn, pars )
%       u1,v1 - 1xN each - points to be transformed (undistorted points, x1)
%       uvn - 2x1 - the no-distortion point (computed in camrdundistort)
%       pars - parameters structure with the following fields:
%               k - distortion coefficient
%       u2,v2 - 1xN each - transformed (distorted, x2) points
%
%   This method uses Newton's iteration method for finding the resulting
%   coordinates of x2 by finding root of the following polynomial in x2:
%
%                       D
%   f( x2 ) = x1 - ------------ * x2,
%                   1 + sum(k)
%
%   where
%
%   D = 1 + k(1)*( ||x2||/||xn|| )^2 + k(2)*( ||x2||/||xn|| )^4 +
%         + k(3)*( ||x2||/||xn|| )^6 + ...
%
% See also: RDPOLYFWD, RDPOLYINIT, RDDIVINIT

% Copyright 2008 Ondrej Sychrovsky (sychro1@fel.cvut.cz) FEE CTU
 
K = 1 + sum( p.k(:) );
r02 = uvn(1)^2 + uvn(2)^2;

u2 = u1;
v2 = v1;

for ii = 1:20,
    % Newton's method
    [D,Dcoeff] = rdpolygetD( [u2;v2], p.k, r02 );
    
    lambda = -K./Dcoeff;
  
    u2v2_hist = [u2;v2];
    
    u2 = u2 - lambda .* ( u1 - D./K.*u2 );
    v2 = v2 - lambda .* ( v1 - D./K.*v2 );
     
    dist = sum( [ u2 - u2v2_hist(1,:); v2 - u2v2_hist(2,:) ].^2, 1 );
    if( max( dist(:) ) < 1e-4 ),
        break;
    end
    
end

if nargout < 2
    u2 = [u2;v2];
end
 
return
function [ D, Dcoeff ] = rdpolygetD( x_d, k, r02 )
% RDPOLYGETD   Computes the distortion coefficient D in polynomial rd model
%
%   D = RDPOLYGETD( XD, K, R0^2 ) Computes the coefficient D for
%       each point in xd:
%
%       rd = sqrt( xd(1)^2 + xd(2)^2 );
%       D = 1 + k(1)*( rd/r0 )^2 + k(2)*( rd/r0 )^4 +
%             + k(3)*( rd/r0 )^6 + ...
%
%       xd are point coordinates, one column for each point.
%           The size is 2xN.
%       k is the coefficients vector.
%       r0 is the distance to no-distortion point in the
%           image.
%
%   [ D, DCOEFF ] = RDPOLYGETD( XD, K, R0^2 ) Also computes DCOEFF
%       for the backwards transformation.
%
%       Dcoeff = 1 + 3*k(1)*( rd/r0 )^2 + 5*k(2)*( rd/r0 )^4 +
%             + 7*k(3)*( rd/r0 )^6 + ...
%
%   See also: RDPOLYBCK, RDPOLYINIT, RDPOLYFWD

% Copyright 2008 Ondrej Sychrovsky (sychro1@fel.cvut.cz), FEE CTU Prague
% Revision 2008-10-08, Ondrej Sychrovsky

% squared radius
r2 = sum( x_d.^2, 1 );

D = 1;
for ii = 1:length(k),
    D = D + k(ii)*(r2./r02).^ii;
end

if( nargout == 2 ),
    Dcoeff = 1;
    for ii = 1:length(k),
        Dcoeff = Dcoeff + (2*ii+1)*k(ii)*(r2./r02).^ii;
    end    
end


