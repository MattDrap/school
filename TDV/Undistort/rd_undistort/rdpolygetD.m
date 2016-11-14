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


