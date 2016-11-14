function [ Rt, X ] = RtXun_ba( Rt, K, X, u, Xu )
%RTXUN_BA  Bundle adjustment of N-view calibrated geometry.
%
%   [ Rt, X ] = RtXun_ba( Rt, K, X, u, Xu  )
%
%   Rt .. cell, Rt{i} is camera without K, i.e [R t]
%   K  .. internal calibration matrix
%   X .. scene points, euclidean
%   u .. image points, u{i} are the points in the i-th camera, euclidean
%   Xu .. scene-to-image correspondences, Xu{i} for i-th camera.


% (c) 2008-11-28, Martin Matousek
% Last change: $Date::                            $
%              $Revision$

ncam = length( Rt );
npts = size( X, 2 );
Xsel = cell( 1, ncam );

x0 = nan( 6, ncam );
for c=1:ncam
  x0( 1:3, c ) = - Rt{c}(:,1:3) \ Rt{c}(:,4);
  x0( 4:6, c ) = R2aa( Rt{c}(:,1:3) );
  Xsel{c} = sort( Xu{c}(:,1) )';
end

X = vnz( e2p(X) );

x0 = [ X(:); x0(:) ];

nz2 = length( [ Xsel{:} ] ); % number of image points

% indices for construction of sparse jacobian
JX_ilist = repmat( [ 1:(2*nz2) ]', 1, 4 );
JC_ilist = repmat( [ 1:(2*nz2) ]', 1, 6 );


JX_jlist = nan( nz2, 1 );
JC_jlist = nan( nz2, 1 );

jn = 0;

for c=1:ncam
  JX_jlist(jn + [1:length( Xsel{c} ) ] ) = Xsel{c} - 1;
  JC_jlist(jn + [1:length( Xsel{c} ) ] ) = c - 1;
  jn = jn + length( Xsel{c} );
end

% double - x and y coordinate
dinx = [ 1:nz2; 1:nz2 ];
dinx = dinx(:);

JX_jlist = JX_jlist( dinx );
JX_jlist = [ JX_jlist*4+1 JX_jlist*4+2 JX_jlist*4+3 JX_jlist*4+4];

JC_jlist = JC_jlist( dinx );
JC_jlist = [ JC_jlist*6+1 JC_jlist*6+2 JC_jlist*6+3 ...
             JC_jlist*6+4 JC_jlist*6+5 JC_jlist*6+6 ];

err0 = dz(x0);

x = levmar( x0, @fun, @gHfun, ...
            { 'verbose', 3, 'dfmin',  sum( err0.^2) * 1e-3, ... %0.01, ...
              'maxiter', 50 } );

err = dz(x);

X = p2e(reshape( x(1:(npts*4)), 4, npts ));
x = reshape( x((npts*4+1):end), 6, ncam );

for c=1:ncam
  Rt{c}(:,1:3) = a2R( x( 4:6, c ) );
  Rt{c}(:,4) = - Rt{c}(:,1:3) * x( 1:3, c );
end

err0 = err0(1:2:end).^2 + err0(2:2:end).^2;
err = err(1:2:end).^2 + err(2:2:end).^2;

fprintf( 'RMS %f->%f\n', sqrt( mean( err0 ) ), sqrt( mean( err ) ) );

% ------------------------------------------------------------------------------
function [g H] = gHfun( x )
% gradient and Hessian approximate
[delta_z J] = dz_jaco( x );
g = J' * delta_z(:); 
H = J' * J;
end
% ------------------------------------------------------------------------------
function f = fun( x )
% objective function
delta_z = dz( x ); 
f = 0.5 * sum( delta_z.^2 ); 
end

% ------------------------------------------------------------------------------
function [err0, J] = dz_jaco( x )
% residues and Jacobian of residues, evaluated numerically

err0 = dz( x );
delta = 1e-10;

% J part for X - points are geometrically independent, so
% three columns for three coordinates in one step, then sparsifying
x1 = x; x1(1:4:(4*npts)) = x1(1:4:(4*npts)) + delta;
x2 = x; x2(2:4:(4*npts)) = x2(2:4:(4*npts)) + delta;
x3 = x; x3(3:4:(4*npts)) = x3(3:4:(4*npts)) + delta;
x4 = x; x4(4:4:(4*npts)) = x4(4:4:(4*npts)) + delta;

err1 = dz( x1 );
err2 = dz( x2 );
err3 = dz( x3 );
err4 = dz( x4 );

JX = [ err1-err0 err2-err0 err3-err0 err4-err0 ] / delta;

% sparsifying JX
JXS = sparse( JX_ilist, JX_jlist, JX );

% J w.r.t. cameras (cameras independent)
% six columns for six coordinates in one step, then sparsifying

JC = nan( length(err0), 6 );
for k=1:6
  xk = x; xk((4*npts+k):6:end) = xk((4*npts+k):6:end) + delta;
  errk = dz( xk );
  JC(:,k) = (errk-err0) / delta;
end

% sparsifying JC 
JCS = sparse( JC_ilist, JC_jlist, JC );

J = [JXS JCS];

% JT = sparse( [], [], [], numel(err0), length(x0), 9 * numel(err0) );
% for i = 1:length(x)
%   xi = x;
%   xi(i) = xi(i) + delta;
%   est = dz( xi );
%   j = ( est  - err0 ) / delta;
%   JT(:,i) = sparse( j(:) );
% end
% isequal( J, JT )

end
% ------------------------------------------------------------------------------
function z = dz( x )

X = ( reshape( x( 1:(4*npts) ), 4, npts ) );
z = [];
for k = 1:ncam
  R = a2R( x( 4*npts + (k-1)*6 + [4:6] ) ); 
  P = K * [ R -R * x( 4*npts + (k-1)*6 + [1:3] ) ]; 

  ur = p2e( P * X( :, Xu{k}(:,1) ) );
  zi = ur - u{k}( :, Xu{k}(:,2) );
  z = [z; zi(:)]; %#ok
end

end

end

% ------------------------------------------------------------------------------
function y = e2p( x )

y = [ x; ones( 1, size( x, 2 ) ) ];
end
function y = p2e(x)

s = size( x, 1 );

y = x( 1:end-1, : ) ./ x( ones( s-1,1) * s, : );

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
end

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
end

function x = vnz( x )

x = x ./ repmat( sqrt( sum( x.^2 ) ), [ size( x, 1 ), 1 ] );
end
