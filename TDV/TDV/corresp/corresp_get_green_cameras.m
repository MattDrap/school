function [i n] = corresp_get_green_cameras( corresp, what )
%CORRESP_GET_GREEN_CAMERAS  Get not-selected cameras having scene-to-image cor.
%
%  [i n] = corresp_get_green_cameras( corresp )
%  [i n] = corresp_get_green_cameras( corresp, 'logical' )
%
%  Input:
%    corresp .. data structure with correspondence tables
%
%  Output:
%    i       .. list of IDs of the green cameras (the first synopsis) or
%               logical array with true values for the green cameras (the
%               second synopsis)
%
%    n       .. counts of scene points every camera can correspond to. Size
%               matching to i (!!).

% (c) 2010-11-19, Martin Matousek
% Last change: $Date::                            $
%              $Revision$

i = false( corresp.n, 1 );
n = zeros( corresp.n, 1 );

for k = 1:corresp.n
  if( ~corresp.camsel(k) && ~isempty( corresp.Xu{k} ) )
    i(k) = true;
    n(k) = length( unique( corresp.Xu{k}(:,1) ) );
  end
end

if( nargin > 1 )
  if( isequal( what, 'logical' ) )
    % ok
  else
    error( 'Unknown value for the 2nd parameter.' );
  end
else
  i = find( i );
  n = n(i);
end
