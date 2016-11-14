function ilist = corresp_get_cneighbours( corresp, i )
%CORRESP_GET_CNEIGHBOURS  Neighb. selected cams related by image-to-image corr.
%
%  ilist = corresp_get_cneighbours( corresp, i )
%
%  Input:
%    corresp .. data structure with correspondence tables
%
%    i       .. the camera
%
%  Output:
%    ilist   .. row vector of neighbouring cameras, that are part of the
%               cluster and are related with the camera i by tentative 
%               image-to-image correspondences.

% (c) 2010-11-22, Martin Matousek
% Last change: $Date::                            $
%              $Revision$

ilist = false( 1, corresp.n );

for q = 1:(i-1)
  ilist(q) = ~isempty( corresp.m{q,i} );
end

for q = (i+1):corresp.n
  ilist(q) = ~isempty( corresp.m{i,q} );
end

ilist = find( ilist & corresp.camsel );
