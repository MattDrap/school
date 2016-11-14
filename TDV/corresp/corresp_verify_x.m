function corresp = corresp_verify_x( corresp, i, inl )
%CORRESP_VERIFY_X  Set unverified scene-to-image correspondences to verified.
%
%  corresp = corresp_verify_x( corresp, i, inl )
%
%  Input
%    corresp .. data structure with correspondence tables
%
%    i       .. the camera index
%
%    inl     .. inliers; indices to scene-to-image correspondences between
%               image points in the camera i and the 3D points. These are
%               kept and propagated. Must be indices to un-verified
%               correspondences. Other un-verified image-to-scene
%               correspondences in the camera i are deleted.
%
%  Output:
%    corresp .. modified corespondences

% (c) 2010-11-09, Martin Matousek
% Last change: $Date::                            $
%              $Revision$

if( isequal( corresp.state, 'join' ) || isequal( corresp.state, 'newx' ) )
  corresp.state = 'verify'; 
  corresp.statecounter = 0;
end

corresp.statecounter = corresp.statecounter + 1;

if( ~isequal( corresp.state, 'verify' ) )
  error( [ 'Bad command order: verify_x can be only after ' ...
           'a join, new_x or verify_x.' ] );
end

if( corresp.camsel(i) ~= 1 )
   error( 'Cannot verify in non-selected camera' );
end

if( any( corresp.Xu_verified{i}(inl) ) )
  error( '(Some) inliers are allready verified' );
end

outl = setdiff( find( ~corresp.Xu_verified{i} ), inl );

% set the correspondences confirmed
corresp.Xu_verified{i}(inl) = true;


% get IDS of 3D points that become verified
xid = corresp.Xu{i}( inl, 1 ); 

good = corresp.Xu_verified{i};


% keep only verified scene-to-image correspondences
corresp.Xu{i} = corresp.Xu{i}( good, : );
corresp.Xu_verified{i} = corresp.Xu_verified{i}( good );
corresp.Xucount(i) = size( corresp.Xu{i}, 1 );

fprintf( '  Scene-to-Image: i%i - %i tent = %i (%i ok)\n', i, ...
         length( outl ), sum( corresp.Xucount(:) ), ...
         sum( [ corresp.Xu_verified{:} ] ) );



% propagate scene-to-image correspondences from this camera
corresp = corresp_propagate_x( corresp, i, xid );

