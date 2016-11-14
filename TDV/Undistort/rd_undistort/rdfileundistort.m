function rdfileundistort( rd, in_file, out_file )
%RDFILEUNDISTORT  Undistort single image file.
%
%  rdfileundistort( rd, in_file, out_file )
%
%  Input:
%    rd .. radial distortion data structure
%    in_file .. input (distorted) image file to read, can be missing/empty
%    out_file .. output (undistorted) image file to write, can be missing/empty
%
%  If either file is missing, the file selection dialog is used to choose.

% (c) 2010-09-13, Martin Matousek
% Last change: $Date::                            $
%              $Revision$


if( nargin < 2 ), in_file = []; end
if( nargin < 3 ), out_file = []; end

if( isempty( in_file ) )
  [f p] = uigetfile( '*.jpg;*.jpeg;*.png', 'Load input image' );
  in_file = fullfile(p,f);
end

im = imread( in_file );

if( isempty( out_file ) )
  [f p] = uiputfile( '',  'Save undistorted image' );
  out_file = fullfile(p,f);
end

sz = size( im );

if( ~isequal( sz(1:2), rd.osize ) )
  error 'Input image has wrong size';
end

imu = rdimundistort( rd, im );

imwrite( imu, out_file );
