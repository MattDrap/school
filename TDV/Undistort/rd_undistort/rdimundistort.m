function imu = rdimundistort( rd, im )
% RDIMUNDISTORT    Undoes radial distortion in a raw image.
%
%   IMU = RDIMUNDISTORT( RD, IM ) transfers a radially distorted image IM
%       to an undistorted image IMU. 
 
% (c) Radim Sara (sara@cmp.felk.cvut.cz) FEE CTU Prague, 13 Sep 07
% Last modified: Ondrej Sychrovsky 2009-01-19

sz = rd.osize;
  
[u1, v1] = ndgrid( 1:sz(1), 1:sz(2) );

[u, v] = rddistort(u1, v1, rd);

imu = zeros( size( im ), class( im ) );

if( isa( im, 'double' ) )
  for d = 1:size( im, 3 )
    imu(:,:,d) = interp2(im(:,:,d), v, u);
  end
else
  for d = 1:size( im, 3 )
    tmp = interp2( double(im(:,:,d)), v, u );
    eval( [ 'imu(:,:,d) = ' class( im ) '(tmp);' ] );
  end
end
