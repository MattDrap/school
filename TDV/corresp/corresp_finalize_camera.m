function corresp = corresp_finalize_camera( corresp )
%CORRESP_FINALIZE_CAMERA  Finalise a join of a camera.
%
%  corresp = corresp_finalize_camera( corresp )

% (c) 2010-11-09, Martin Matousek
% Last change: $Date::                            $
%              $Revision$

if( ~corresp.lastjoin )
  error( 'There is no previously joined camera to finalise.' );
end

if( corresp.camsel( corresp.lastjoin ) ~= 1 )
  error( 'Internal data corrupted.' )
end

corresp.state = 'clear';

i = corresp.lastjoin;

for q = find( corresp.camsel == 1 )
  if( q == i ), continue; end
  
  if( q < i )
    [i1, i2] = deal( q, i );
  else
    [i1, i2] = deal( i, q );
  end
  
  if( ~isempty( corresp.m{i1,i2} ) )
    error( [ 'Found correspondences between cameras %i-%i. ' ...
             'No corresspondences must remain between selected cameras.' ], ...
             i1, i2 )
  end

  if( ~isempty( corresp.m{i2,i1} ) )
    error( 'Internal data corrupted.' )
  end
end

for i = find( corresp.camsel )
  if( ~all( corresp.Xu_verified{i} ) )
    error( [ 'There are some unverified scene-to camera correspondences ' ...
             'in the selected set (cam %i).' ] , i )
  end
end

corresp.lastjoin = 0;



