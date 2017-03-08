function [ Xucount Xu_verifiedcount] = corresp_get_Xucount( corresp, ilist )
%CORRESP_GET_XU  Get scene-to-image correspondence counts.
%
%  [ Xucount Xu_verifiedcount] = corresp_get_Xucount( corresp, ilist )
%
%  Input:
%    corresp .. data structure with correspondence tables
%
%    ilist   .. list of camera IDs
%
%  Output:
%    Xucount .. list of counts of scene-to-image point correspondences for
%               every camera in the ilist.
%
%    Xu_verifiedcount .. counts of corespondences in the confirmed state.

% (c) 2010-11-19, Martin Matousek
% Last change: $Date::                            $
%              $Revision$

Xucount = corresp.Xucount( ilist );
Xu_verifiedcount = Xucount;
for i = 1:length(ilist)
  Xu_verifiedcount(i) = sum( corresp.Xu_verified{ilist(i)} );
end
