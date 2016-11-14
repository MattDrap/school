function rddirundistort( rd, in_dir, out_dir )
%RDDIRUNDISTORT  Undistort all image files in a directory.
%
%  rddirundistort( rd, in_dir, out_dir )
%
%  Input:
%    rd .. radial distortion data structure
%    in_dir .. input (distorted) image files directory, can be missing/empty
%    out_dir .. output (undistorted) image files directory, can be missing/empty
%
%  If either directory is missing, the directory selection dialog is used
%  to choose.

% (c) 2010-09-13, Martin Matousek
% Last change: $Date::                            $
%              $Revision$
% Permissions to use:
%   This software can be used for educational purposes by FEE students. 
%   Other use requires a licence.


if( nargin < 2 ), in_dir = []; end
if( nargin < 3 ), out_dir = []; end

if( isempty( in_dir ) )
    in_dir = uigetdir( '', 'Input directory' );
end

if( isempty( out_dir ) )
    out_dir = uigetdir( '', 'Output directory' );
end

if( ~exist( in_dir, 'dir' ) )
  error( 'Input directory ''%s'' does not exists.', in_dir );
end

if( exist( out_dir, 'dir' ) )
  error( 'Output directory ''%s'' must not exists.', out_dir );
end

mkdir( out_dir );

if( ~exist( out_dir, 'dir' ) )
  error( 'Cannot create output directory ''%s''.', out_dir );
end

files = dir( in_dir );

for file = files'
  if( length( file.name ) > 5 && ~file.isdir && ...
    ~isempty( regexpi( file.name, '\.(jpg|jpeg|png|tif|tiff)$' ) ) )
    in_file = fullfile( in_dir, file.name );
    out_file = fullfile( out_dir, file.name );
    
    fprintf( 'Undistorting %s -> %s\n', in_file, out_file );
    rdfileundistort( rd, in_file, out_file )
  end
end

fprintf( 'Done.\n' );
