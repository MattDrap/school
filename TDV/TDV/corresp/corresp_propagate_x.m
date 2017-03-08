function corresp = corresp_propagate_x( corresp, i, xids )
%CORRESP_PROPAGATE_X Propagete scene-to-image correspondences

% (c) 2010-11-09, Martin Matousek
% Last change: $Date::                            $
%              $Revision$

if( ~corresp.camsel(i) )
  error( 'Cannot propagate from non-selected camera' );
end

xinx = findinx( corresp.Xu{i}(:,1), xids(:) );

% selected corresponding point ids in the camera i (not unique):
i_xids = corresp.Xu{i}( xinx, 1 ); 
i_uids = corresp.Xu{i}( xinx, 2 );


% i1,q
for q = 1:corresp.n
  % also red must be considered !
  
  if( q == i ), continue; end

  i1 = min( q, i );
  i2 = max( q, i );
  
  if( i < q )
    % correspondences are in m{i,q}
    [ci cq] = deal( 1, 2 ); % i corresponds to the first col, q to the second
  else
    % correspondences are in m{q,i}
    [ci cq] = deal( 2, 1 ); % i corresponds to the second col, q to the first
  end
    
  if( ~isempty( corresp.m{i1,i2} ) )
    [inx_i inx_iq] = findinx( i_uids,  corresp.m{i1,i2}(:,ci) );

    if( ~isempty( inx_i ) )
      xid = i_xids( inx_i );
      q_uid = corresp.m{i1,i2}( inx_iq, cq );


      new_Xu = setdiff( [xid q_uid], corresp.Xu{q}, 'rows' );
      
      
      nxu = size( corresp.Xu{q}, 1 );
      corresp.Xu{q} = [ corresp.Xu{q}; new_Xu ];
      
      mxu = size( corresp.Xu{q}, 1 );
      
      corresp.Xu_verified{q}((nxu+1):mxu) = false;
      
      corresp.Xucount(q) = size( corresp.Xu{q}, 1 );
      fprintf( '  Scene-to-Image: i%i + %i tent = %i (%i ok)\n', q, ...
               mxu - nxu, sum( corresp.Xucount(:) ), ...
               sum( [ corresp.Xu_verified{:} ] ) );

      
      

      % remove image-to-image correspondences propagated to scene-to-image
      corresp.m{i1,i2}( inx_iq, : ) = [];
      corresp.mcount(i1,i2) = size( corresp.m{i1,i2}, 1 );
      
      fprintf( '  Image-to-Image: pair %i-%i -%i -> %i = %i\n', i1, i2, ...
               length( inx_iq ), corresp.mcount(i1,i2), ...
               sum( corresp.mcount(:) ) );

      
    end
  end
end


% ------------------------------------------------------------------------------
function [inx1 inx2] = findinx( i1, i2 )
%
% inx1 = [];
% inx2 = [];
% for i = 1:size( i1,1)
%   for j = 1:size( i2, 1 )
%     if( isequal( i1(i,:), i2(j,:) ) )
%       inx1 = [inx1; i];%#ok
%       inx2 = [inx2; j];%#ok
%     end
%   end
% end


inx1 = [];
inx2 = [];
for i = 1:size( i1,1)
  q2 = find( i1(i) == i2 );
  q1 = zeros( size( q2 ) ) + i;
  inx1 = [inx1; q1];%#ok
  inx2 = [inx2; q2];%#ok
end
