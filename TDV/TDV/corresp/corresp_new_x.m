function corresp = corresp_new_x( corresp, i1, i2, inl, xid )
%NEW_X  New 3D points.
%
%  [ corresp, xid ] = new_x( corresp, i1, i2, inl, xid )
%
%  Input
%    corresp .. data structure with correspondence tables
%    i1, i2  .. camera pair
%
%    inl     .. inliers; indices to image-to-image correspondences between
%               the two cameras.
%
%    xid     .. IDs of 3D points, reconstructed from inliers. Must have the
%               same size as inl
%
%  Output:
%    corresp .. modified corespondences
%
%  Scene-to-image correspondences given inliers and 3D poit IDs are
%  established and image-to-image correspondences between i1 and i2 are removed.

% (c) 2010-11-09, Martin Matousek
% Last change: $Date::                            $
%              $Revision$

if( isequal( corresp.state, 'join' ) )
  corresp.state = 'newx'; 
  corresp.statecounter = 0;
end

corresp.statecounter = corresp.statecounter + 1;

if( ~isequal( corresp.state, 'newx' ) )
  error( 'Bad command order: new_x can be only after a join or new_x.' );
end

if( i1 > i2 )
  [i1, i2] = deal( i2, i1 );
end

if( ~( ( corresp.camsel(i1) == 1 && corresp.lastjoin == i2 ) || ...
       ( corresp.camsel(i2) == 1 && corresp.lastjoin == i1 ) ) )
  error( [ 'New points can be triangulated only between the latest\n' ...
           'joined camera and some allready selected camera.' ] );
end

if( ~isequal( size( inl ), size( xid ) ) )
  error( 'Inliers and IDs of 3D point size must have the same size' );
end

fprintf( '\nNew X %i-%i --------------\n', i1,i2 );



xinl1 = size( corresp.Xu{i1}, 1 ) + [1:length(xid)];
xinl2 = size( corresp.Xu{i2}, 1 ) + [1:length(xid)];

n_new = length(inl);

corresp.Xu{i1} = [ corresp.Xu{i1}; [ xid(:) corresp.m{i1,i2}(inl(:),1) ] ];
corresp.Xucount(i1) = corresp.Xucount(i1) + n_new;
corresp.Xu_verified{i1}( end+[1:n_new] ) = true;

fprintf( '  Scene-to-Image: i%i + %i ok = %i (%i ok)\n', i1, n_new, ...
         sum( corresp.Xucount(:) ), sum( [ corresp.Xu_verified{:} ] ) );

corresp.Xu{i2} = [ corresp.Xu{i2}; [ xid(:) corresp.m{i1,i2}(inl(:),2) ] ];
corresp.Xucount(i2) = corresp.Xucount(i2) + n_new;
corresp.Xu_verified{i2}( end+[1:n_new] ) = true;

fprintf( '  Scene-to-Image: i%i + %i ok = %i (%i ok)\n', i2, n_new, ...
         sum( corresp.Xucount(:) ), sum( [ corresp.Xu_verified{:} ] ) );



% remove all edges between i1 and i2
tmp = size( corresp.m{i1,i2}, 1 );
corresp.m{i1,i2} = [];
corresp.mcount(i1,i2) = 0;

fprintf( '  Image-to-Image: pair %i-%i -%i -> 0 = %i\n', i1, i2, ...
         tmp, sum( corresp.mcount(:) ) );


% propagate image-to-scene correspondences
corresp = corresp_propagate_x( corresp, i1, xid );
corresp = corresp_propagate_x( corresp, i2, xid );

