function m12 = corresp_get_m( corresp, i1, i2 )
%CORRESP_GET_M  Get pairwise image-to-image correspondences.
%
%  m12 = corresp_get_m( corresp, i1, i2 )
%
%  Input:
%    corresp .. data structure with correspondence tables
%
%    i1, i2  .. camera pair
%
%  Output:
%    m12     .. image-to-image point correspondences between camera i1 and i2.
%               Rows [ ... ; u1 u2; ... ], where u1 is ID of image point in
%               the image i1 and u2 is id of image point in the image i2.

% (c) 2010-11-19, Martin Matousek
% Last change: $Date::                            $
%              $Revision$

if( i1 == i2 ), error( 'Pairs must be between different cameras' ), end

if( i1 < i2 )
  m12 = corresp.m{i1,i2};
elseif( ~isempty( corresp.m{i2,i1} ) )
  m12 = corresp.m{i2,i1}(:, [2 1] );
else
  m1 = [];
end
