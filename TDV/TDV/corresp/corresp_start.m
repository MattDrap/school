function corresp = corresp_start( corresp, i1, i2, inl, xid )
%CORRESP_START  Select the first two cameras. 
%
%  corresp = corresp_start( corresp, i1, i2, inl )
%
%  Input:
%    corresp .. data structure with correspondence tables
%
%    i1, i2  .. camera pair
%
%    inl     .. inliers; indices to image-to-image correspondences between
%               the two cameras.
%
%    xid     .. IDs of 3D points, reconstructed from inliers. Must have the
%               same size as inl
%
%  Output:
%    corresp .. modified data structure with correspondence tables

% (c) 2010-11-09, Martin Matousek
% Last change: $Date::                            $
%              $Revision$

if( ~isequal( corresp.state, 'init' ) )
  error( 'Cannot run start now.' );
end

fprintf( '\nAttaching %i,%i ---------\n', i1, i2 );

corresp.camsel(i1) = 1;
corresp.camsel(i2) = 1;
corresp.lastjoin = i2;

corresp.state = 'join';
corresp = corresp_new_x( corresp, i1, i2, inl, xid );

corresp.state = 'clear';
corresp.lastjoin = 0;
