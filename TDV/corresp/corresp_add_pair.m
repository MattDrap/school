function corresp = corresp_add_pair( corresp, i1, i2, m12 )
%CORRESP_ADD_PAIR  Add pairwise correspondences into data structure.
%
%  corresp = corresp_add_pair( corresp, i1, i2, m12 )
%
%  Input:
%    corresp .. data structure with correspondence tables
%
%    i1, i2  .. camera pair
%
%    m12     .. image-to-image point correspondences between camera i1 and i2.
%               Rows [ ... ; u1 u2; ... ], where u1 is ID of image point in
%               the image i1 and u2 is id of image point in the image i2.
%
%  Output:
%    corresp .. modified data structure with correspondence tables

% (c) 2010-11-09, Martin Matousek
% Last change: $Date::                            $
%              $Revision$

if( ~isequal( corresp.state, 'init' ) )
  error( 'Cannot add correspondences now.' );
end

if( i1 == i2 ), error( 'Pairs must be between different cameras' ), end
if( i1 < 1 || i2 < 1 || i1 > corresp.n || i2 > corresp.n )
  error( 'Image indices must be in range 1..%i.', corresp.n );
end

if( size( m12, 2 ) ~= 2 )
  error( 'Point correspondences must be in n x 2 matrix.' )
end

% ensure correct order
if( i1 > i2 )
  [i1 i2] = deal( i2, i1 );
  m12 = m12( :, [2 1] );
end

if( ~isempty( corresp.m{i1,i2} ) )
  error( 'Pair %i-%i allready have correspondences.', i1,i2);
end

corresp.m{i1,i2} = m12;
corresp.mcount(i1,i2) = size( m12, 1 );

fprintf( '  Image-to-Image: pair %i-%i + %i = %i\n', i1, i2, size( m12, 1 ), ...
         sum( corresp.mcount(:) ) );
