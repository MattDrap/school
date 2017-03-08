function [ corresp, xid ] = corresp_join_camera( corresp, i, inl )
%CORRESP_JOIN_CAMERA  Add a camera to the set of selected cameras.
%
%  [ corresp, xid ] = corresp_join_camera( corresp, i, inl )
%
%  Input
%    corresp .. data structure with correspondence tables
%
%    i       .. the camera index
%
%    inl     .. inliers; indices to scene-to-image correspondences between
%               image points in the camera i and the 3D points. These are
%               kept and propagated. Other image-to-scene correspondences in the
%               camera i are deleted.
%
%  Output:
%    corresp .. modified corespondences
%
%    xid     .. identifiers of the 3D points that are kept

% (c) 2010-11-09, Martin Matousek
% Last change: $Date::                            $
%              $Revision$

if( ~isequal( corresp.state, 'clear' ) )
  error( 'Bad command order: cannot join a camera now.' );
end

if( corresp.lastjoin )
  error( 'The previous join was not properly finalised.' );
end

if( corresp.camsel(i) ~= 0 || isempty( corresp.Xu{i} ) )
   error( 'Cannot join non-green camera' );
end

if( any( corresp.Xu_verified{i} ) )
  error( 'Data structures corruption' );
end

fprintf( '\nAttaching %i ------------\n', i );

corresp.state = 'join';

outl = setdiff( 1:size( corresp.Xu{i}, 1 ), inl );

% add this camera to the set
corresp.camsel(i) = 1;
corresp.lastjoin = i;

% confirm the inliers
corresp.Xu_verified{i}(inl) = true;


% keep only the selected scene-to-image correspondences
corresp.Xu{i} = corresp.Xu{i}( inl, : );
corresp.Xu_verified{i} = corresp.Xu_verified{i}( inl );
corresp.Xucount(i) = size( corresp.Xu{i}, 1 );

fprintf( '  Scene-to-Image: i%i - %i tent (%i->ok) = %i (%i ok)\n', i, ...
         length( outl ), length( inl ), sum( corresp.Xucount(:) ), ...
         sum( [ corresp.Xu_verified{:} ] ) );


% get IDS of 3D points that are kept
xid = corresp.Xu{i}( :, 1 ); 


% propagate scene-to-image correspondences from this camera
corresp = corresp_propagate_x( corresp, i, xid );

