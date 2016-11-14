function i = corresp_get_selected_cameras( corresp, what )
%CORRESP_GET_SELECTED_CAMERAS  Get allready selected cameras.
%
%  i = corresp_get_selected_cameras( corresp )
%  i = corresp_get_selected_cameras( corresp, 'logical' )
%
%  Input:
%    corresp .. data structure with correspondence tables
%
%  Output:
%    i       .. list of IDs of selected cameras (the first synopsis) or
%               logical array with true values for the selected cameras (the
%               second synopsis)

% (c) 2010-11-19, Martin Matousek
% Last change: $Date::                            $
%              $Revision$

if( nargin > 1 )
  if( isequal( what, 'logical' ) )
    i = corresp.camsel;
  else
    error( 'Unknown value for the 2nd parameter.' );
  end
else
  i = find( corresp.camsel );
end
