function [R,t] = RtXu_ba( R0, t0, K, X, u )
%RTXU_BA  Nonlinear iterative refinement of calibrated single view resection.
%
%   [R t] = RtXu_ba( R, t, K, X, u )
%
%   TODO
%
%   Input:
%     R, t, K  .. single view orientation and internal
%                 calibration, P = K * [ R | t ]
%     X        .. spatial points, euclidean (3xn)
%     u        .. corresponding projections of X, euclidean (2xn)
%
%   Output:
%     R, t  .. updated orientation.

% (c) 2009-01-08, Martin Matousek
% Last change: $Date::                            $
%              $Revision$

a0 = R2aa( R0 );  % axis-angle representation

x0 = [a0;t0];

X = vnz( e2p(X) );

x = levmar( x0, @fun, @gHfun, ...
            { 'verbose', 1, 'dfmin', 0.01, ...
              'maxiter', 5 }, ...
            K, X, u );

R = a2R( x(1:3) ); 
assert( isreal( R ) );
t = x(4:6);

% ------------------------------------------------------------------------------
% gradient

function [g H] = gHfun( x, K, X, u )
[delta_z J] = dz_jaco( x, K, X, u ); % 2n x 6
g = J' * delta_z(:); 
H = J' * J;

% ------------------------------------------------------------------------------
% objective function

function f = fun( x, K, X, u )
delta_z = dz( x, K, X, u ); % 2xn
fi = 0.5 * sum( delta_z.^2 ); 
f = sum( fi );

% ------------------------------------------------------------------------------
% residues and Jacobian of residues, evaluated numerically

function [err0, J] = dz_jaco( x0, K, X, u )
nX = size( u, 2 ); 
ncam = 1;
nz = nX * ncam * 2; % 2 - two image coordinates

err0 = dz( x0, K, X, u );

delta = 1e-4;

J = zeros( nz, 6 );
for i = 1:6
  x = x0;
  x(i) = x(i) + delta;
  j = ( dz( x, K, X, u ) - err0 ) / delta;
  J(:,i) = j(:);
end

% ------------------------------------------------------------------------------
% residues

function err = dz( x, K, X, u )
n = size( u, 2 ); 

R = a2R( x(1:3) ); 
t = x(4:6);

ux = K * [ R t ] * X;

err = [ux(1,:) ./ ux(3,:); ux(2,:) ./ ux(3,:)] - u;

function [a sin_alpha cos_alpha] = R2aa( R )
% Can be solved using logm(R) (excluding rotation by 0 and pi), but
% the following is faster.

dR = det( R );
if( dR < 0 )
  error( 'Rotation matrix must have positive unit determinant' );
end

% To derive the following, examine Rodrigues' rotation formula for R - R':
%   R - R' = 2 * sqc( a ) * sin( alpha )
% and for Tr(R):
%   trace( R ) = 1 - 2 * cos( alpha )

sa = [R(3,2)-R(2,3); R(1,3)-R(3,1); R(2,1)-R(1,2)] / 2; % sin_alpha * ax

sin_alpha = sqrt( sum( sa.^2 ) );
cos_alpha = ( trace(R) - 1 ) / 2;

if( sin_alpha == 0 ) % hard zero test suffices (see note bellow)
  a = [1;0;0];
else
  a = sa / sin_alpha;
  % This has standard accuracy for alpha > sqrt( realmin ). Then the accuracy
  % smoothly degrades as alpha approaches sqrt( eps(0) ). For 
  % alpha <= sqrt( eps(0) ) we compute sin_alpha = 0 because of square there.
  % Overal, the accuracy of 'sa' here is better than using EIG.
end

if( nargout < 3 )  % [a alpha] required
  sin_alpha = atan2( sin_alpha, cos_alpha );

  if( nargout < 2 )  % a required
    a = a * sin_alpha;
  end
end

function R = a2R( a )
alphaq = a(1).^2 + a(2).^2 + a(3).^2; % faster than sum( a.^2 )

if( alphaq < eps )
    % do not divide, sin(alpha)/alpha = 1, 1-cos(alpha) = 0
    
    R = [1 -a(3) a(2); a(3) 1 -a(1); -a(2) a(1) 1]; % R = E + sqc( a );
    return;
end

alpha = sqrt( alphaq );
a = a / alpha;

A = [0 -a(3) a(2); a(3) 0 -a(1); -a(2) a(1) 0]; % A = sqc( a );

R = eye(3) + A * sin( alpha ) + A^2 * ( 1 - cos( alpha ) );
% R = expm( A * alpha ), but previous is 10x faster

function x = vnz( x )

x = x ./ repmat( sqrt( sum( x.^2 ) ), [ size( x, 1 ), 1 ] );

function y = e2p( x )

y = [ x; ones( 1, size( x, 2 ) ) ];

